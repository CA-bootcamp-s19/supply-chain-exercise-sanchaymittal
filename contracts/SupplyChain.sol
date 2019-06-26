/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/
///@title Supply Chain
///@author Sanchay Mittal
///@notice Offers basic functionality of Supply Chain, which includes selling, buying, receiving and enquery regarding a product.
///@dev All the functions are fully working, And are prepared for counter meaasures.
pragma solidity ^0.5.0;

contract SupplyChain {

  //
  // State Variable
  //

  ///@notice set owner
  address owner;

  ///@notice skuCount to track the most recent sku
  uint skuCount;

  ///@notice A public mapping that maps the SKU(a number) to an Item.
  mapping (uint => Item) public items;

  ///@notice Enum named state represents the items current state.
  enum State{
    ForSale,
    Sold,
    Shipped,
    Received
  }

  ///@notice Struct Item to keep track of details for each item.
  ///@dev Payable is added to keep track of details for each item.
  struct Item{
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }

  //
  // Events
  //
  
    event LogForSale(uint sku);
    event LogSold(uint sku);
    event LogShipped(uint sku);
    event LogReceived(uint sku);

  //
  // Modifier
  //

  ///@notice Checks the owner of the contract
  modifier checkOwner(){require(msg.sender == owner); _;}

  ///@notice verify the transaction caller using address.
  modifier verifyCaller (address _address) {require (msg.sender == _address); _;}
  
  ///@notice Checks the amount of balance paid.
  modifier paidEnough(uint _price) {require(msg.value >= _price); _;}
  
  ///@notice Refund the excess amount
  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }
  
  ///@notice Checks the state for ForSale
  modifier forSale(uint _sku){
    require(items[_sku].state == State.ForSale);
    _; 
  }

  ///@notice Checks the state for Sold
  modifier sold(uint _sku){
    require(items[_sku].state == State.Sold);
    _;
  }

  ///@notice Checks the state for Shipping.
  modifier shipped(uint _sku){
    require(items[_sku].state == State.Shipped);
    _;
  }

  ///@notice Checks the state for Received.
  modifier received(uint _sku){
    require(items[_sku].state == State.Received);
    _;
  }


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
       owner = msg.sender;
       skuCount = 0;
  }

  ///@notice AddItem to the items list.
  ///@dev Mapping items is updated with item details.
  ///@param _name Name of the Item.
  ///@param _price Price of the Item.
  ///@return Success of Updation.
  function addItem(string memory _name, uint _price) public returns(bool){
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

  function buyItem(uint sku)
    public
    payable
    forSale(sku)
    paidEnough(items[sku].price)
    checkValue(sku)
  {
    uint Price = items[sku].price;

    items[sku].buyer = msg.sender;
    items[sku].seller.transfer(Price);
    items[sku].state = State.Sold;
    
    emit LogSold(sku);
  }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function shipItem(uint sku)
    public
    sold(sku)
    verifyCaller(items[sku].seller)
    {
      items[sku].state = State.Shipped;
      emit LogShipped(sku);
    }

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint sku)
    public
    shipped(sku)
    verifyCaller(items[sku].buyer)
    {
      items[sku].state = State.Received;
      emit LogReceived(sku);
    }

  /* We have these functions completed so we can run tests, just ignore it :) */
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

}