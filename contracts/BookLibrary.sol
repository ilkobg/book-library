// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BookLibrary is Ownable {
    struct Book {
        string name;
        uint16 copies;
        address[] bookBorrowedAddresses;
    }

    bytes32[] public bookKey;

    event LogNewBook(string name, uint16 copies);
    event LogNewBorrow(address user, string name);
    event LogNewReturn(address user, string name);

    mapping(bytes32 => Book) public books;
    mapping(address => mapping(bytes32 => bool)) public borrowedBooks;

    modifier isBooked (bytes32 bookId) {
        require(books[bookId].copies > 0, "No copies left from this book");
        require(!borrowedBooks[msg.sender][bookId], "This book is already borrowed by this user");
        _;
    }

    function addBook(string memory _name, uint16 _copies) external onlyOwner {
        require(_copies > 0, "Copies must be at least 1");
        require(bytes(_name).length > 0, "Name is not valid");
        bytes32 _bookKey = keccak256(abi.encodePacked(_name));
        require(bytes(books[_bookKey].name).length == 0, "Book is already added");

        address[] memory borrowed;
        Book memory newBook = Book(_name, _copies, borrowed);
        books[_bookKey] = newBook;
        bookKey.push(_bookKey);
        emit LogNewBook(_name, _copies);
    }

    function borrowBook(bytes32 _bookId) external isBooked(_bookId) {
        Book storage book = books[_bookId];
        borrowedBooks[msg.sender][_bookId] = true;
        book.bookBorrowedAddresses.push(msg.sender);
        book.copies--;
        emit LogNewBorrow(msg.sender, books[_bookId].name);
    }

    function returnBook(bytes32 _bookId) external {
        Book storage book = books[_bookId];
        borrowedBooks[msg.sender][_bookId] = false;
        book.copies++;
        emit LogNewReturn(msg.sender, books[_bookId].name);
    }

    function getAllAddressesBorrowedBook(bytes32 _bookId) external view returns (address[] memory _book) {
        Book memory book = books[_bookId];
        return book.bookBorrowedAddresses;
    }
}
