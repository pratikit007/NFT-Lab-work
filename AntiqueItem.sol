// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./ERC721Standard.sol";

// This is token for antique items for buying and selling. 
contract AntiqueItem is ERC721Standard {
    
    uint256 public pendingItemCount;
    
    struct Item {
        uint256 id;
        string title;
        uint256 price;
        string date;
        string authorName;
        address payable author;
        address payable owner;
        SoldStatus status;
        
    }
    
    enum SoldStatus {FOR_SALE, SOLD}
    
    Item[] public Items;
    
    constructor(string memory _name, string memory _symbol) ERC721Standard(_name,_symbol) {
        
    }
    
    function createTokenAndSellItem(
        string memory _title, 
        string memory _date, 
        string memory _authorName,
        uint256 _price, 
        ) public {
            require(bytes(_title).length > 0, 'The title cannot be empty');
            require(bytes(_date).length > 0, 'The date cannot be empty');
            require(bytes(_authorName).length > 0, 'The authorName cannot be empty');
            require(_price > 0 , 'The price cannot be zero');
            
            Item memory _Item = Item ({
                id : 0,
                title : _title,
                price : _price,
                date : _date,
                authorName : _authorName,
                author : msg.sender,
                owner : msg.sender,
                status: SoldStatus.FOR_SALE,
            });
            Items.push(_Item);
            uint256 _tokenId = Items.length - 1;
            safeMint(msg.sender, _tokenId);
            uint _index = getTokenIndexByTokenID(_tokenId);
            Items[_index].id = _index;
            pendingItemCount++;
        }
        
        function buyItem(uint256 _tokenId) payable public {
            require(!_exists(_tokenId),"nonexistant token");
            uint _index = getTokenIndexByTokenID(_tokenId);
            Item memory _Item = Items[_index];
            require(msg.value >= _Item.price);
            require(msg.sender != address(0));
            
            if (msg.value > _Item.price) {
                msg.sender.transfer(msg.value - _Item.price);
            }
            _Item.owner.transfer(_Item.price);
            transferFrom(_Item.owner, msg.sender, _tokenId);
            Items[_index].owner = msg.sender;
            Items[_index].status = SoldStatus.SOLD;
            pendingItemCount--;
        }
        
        function resellItem(uint256 _tokenId, uint256 _price) payable public {
            require(msg.sender != address(0));
            require(_price > 0);
            address _owner = ownerOf(_tokenId);
            require(msg.sender == _owner);
            uint _index = getTokenIndexByTokenID(_tokenId);
            Items[_index].status = SoldStatus.FOR_SALE;
            Items[_index].price = _price;
            pendingItemCount++;
        }
}
