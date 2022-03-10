// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
contract Nftcontract is ERC721Pausable, Ownable  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    using Strings for uint256;
    uint256 tokenPrice;
    uint256 maxSupply; 
    string public baseURI; 
    uint256 startTime;
    uint256 endTime;
    bool openForWhitelisted = true;
    mapping (address => bool) isWhiteListed;
    
    constructor (
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
         ) 
         ERC721(name_ , symbol_)
         {  
             maxSupply = maxSupply_;
         }
    function mint(
    uint256 nftAmount
        )  
    external
    whenNotPaused
    payable 
    {
    require(msg.sender != address(0), "Address cannot be 0");
    require(block.timestamp > startTime || block.timestamp < endTime,
     "Time requirments not met"
     );
    require(currentSupply() + nftAmount <= maxSupply, "maxSupply Reached");
    uint256 price = tokenPrice * nftAmount;
    require(msg.value == price, "Low Funds");
    if(openForWhitelisted)
    {
    require(isWhitelisted(msg.sender), " Not Whitelist");
    }
    
    for (uint256 i = 0; i < nftAmount; i++)
     {
         _tokenId.increment();
     uint256 tokenId = _tokenId.current();
     
    _mint(msg.sender , tokenId);
    }
    }

    function currentSupply() public view returns(uint256)
    {
        return _tokenId.current();
    }

    function withdrawEth(uint256 _amount)
    external
    onlyOwner
    {
    require
    (_amount <= address(this).balance,
     "Not enough balance");
    payable(msg.sender).transfer(_amount);
    }

    function addWhitelistUser(address[] memory _addresses)
    external
    onlyOwner
    {
        for(uint i = 0; i < _addresses.length; i++){
        isWhiteListed[_addresses[i]] = true;
        }
    }

    function isWhitelisted(address _user)
    public 
    view
    returns(bool)
    {
        return isWhiteListed[_user];
    }

    function addStartTime(uint256 _startTime)
    external
    onlyOwner
    {
        startTime = _startTime;
    }

    function addEndTime(uint256 _endTime)
    external
    onlyOwner
    {
        endTime = _endTime;
    }

    function changeMaxSupply(uint256 _maxsupply)
    external
    onlyOwner{
        maxSupply = _maxsupply;
    }

    function checkMaxSupply()
    external
    view
    returns(uint256)
    {
        return maxSupply;
    }

    
    function setBaseURI(string memory baseURI_) 
        external
        onlyOwner
         {
            require(bytes(baseURI_).length > 0, "Cannot be null");

            baseURI = baseURI_;
    }

    function _baseURI() 
    internal
     view
      override
       returns
        (string memory) {
        return baseURI;
    }

        function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");    
         return string(abi.encodePacked(_baseURI(), tokenId.toString()));
          }
    function changeWhiteListingStatus()
    external
    onlyOwner
    returns(bool)
    {
        openForWhitelisted = !openForWhitelisted;
        return openForWhitelisted;
    }

    function changeTokenPrice(uint256 _price) 
    external 
    onlyOwner
    {
        tokenPrice = _price;
    }

    function checkTokenPrice() 
    external
    view
    returns(uint256)
    {
        return tokenPrice;
    }

    function checkBalance()
    external 
    view
    onlyOwner
    returns(uint256)
    {
    return address(this).balance;
    }

    function pause() public onlyOwner{
          _pause();
    }
    function unpause() public onlyOwner{
          _unpause();
    }
}
