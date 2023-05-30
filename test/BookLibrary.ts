import { ethers } from "hardhat";
import { expect } from "chai";

describe("BookLibrary", function () {
  let bookLibrary;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    const BookLibrary = await ethers.getContractFactory("BookLibrary");
    [owner, user1, user2] = await ethers.getSigners();

    bookLibrary = await BookLibrary.deploy();
    await bookLibrary.deployed();
  });

  it("Should add a new book", async function () {
    const bookName = "Book1";
    const bookCopies = 5;

    const addBookTx = await bookLibrary.addBook(bookName, bookCopies);
    await addBookTx.wait();
    console.log("Book added successfully!");

    const bookKey = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["string"], [bookName]));
    const book = await bookLibrary.books(bookKey);
    console.log("Book name: " + book.name + " book copies: " + book.copies);
    expect(book.name).to.equal(bookName);
    expect(book.copies).to.equal(bookCopies);

    console.log("Book name: " + book.name + " book copies: " + book.copies);
  });
})