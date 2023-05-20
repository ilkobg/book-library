// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BookLibrary is Ownable {
    struct Book {
        string name;
        uint16 copies;
    }

    struct Borrow {
        uint bookId;
        address user;
        uint32 borrowedAt;
        uint32 returnedAt;
    }

    uint availableBooksCount = 0;

    Book[] private books;
    Borrow[] private borrows;

    event NewBook(string name, uint16 copies);
    event NewBorrow(address user, string name, uint time);
    event NewReturn(address user, string name, uint time);

    mapping (uint => uint16) private copiesAvailable; // Available copies for each book
    mapping (uint => address[]) private bookRenters; // Keeps history of all renters of a book

    modifier isBooked (uint bookId) {
        bool found = false;
        for (uint i = 0; i < borrows.length; i++) {
            if (borrows[i].bookId == bookId && borrows[i].user == msg.sender) {
                found = true;
                break;
            }
        }
        require(!found, "Book is already borrowed by this user!");
        _;
    }

    function addBook(string memory _name, uint16 _copies) external onlyOwner {
        require(_copies > 0);
        books.push(Book(_name, _copies));
        uint id = books.length - 1;
        copiesAvailable[id] = _copies;
        availableBooksCount++;
        emit NewBook(_name, _copies);
    }

    function availableBooks() external view returns(string[] memory) {
        string[] memory result = new string[](availableBooksCount);
        uint counter = 0;
        for (uint i = 0; i < books.length; i++) {
            if (copiesAvailable[i] > 0) {
                result[counter] = books[i].name;
            }
            counter++;
        }

        return result;
    }

    function borrow(uint _bookId) external isBooked(_bookId) {
        require(copiesAvailable[_bookId] > 0);
        require(availableBooksCount > 0);
        uint32 time = uint32(block.timestamp);

        bookRenters[_bookId].push(msg.sender);
        borrows.push(Borrow(_bookId, msg.sender, time, 0));
        copiesAvailable[_bookId]--;
        if (copiesAvailable[_bookId] == 0) {
            availableBooksCount--;
        }

        emit NewBorrow(msg.sender, books[_bookId].name, time);
    }

    function returnBook(uint _bookId) external {
        uint32 time = uint32(block.timestamp);

        for (uint i = 0; i < borrows.length; i++) {
            if (borrows[i].bookId == _bookId) {
                require(borrows[i].borrowedAt < time);
                borrows[i].returnedAt = time;
                availableBooksCount++;
                copiesAvailable[_bookId]++;
            }
        }

        emit NewReturn(msg.sender, books[_bookId].name, time);
    }
}
