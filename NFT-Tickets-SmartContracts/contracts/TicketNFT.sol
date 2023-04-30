// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./UserAccount.sol";

contract TicketNFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    // Add a mapping to store events created by each organizer
    mapping(address => uint256[]) private _organizerEvents;

    // burnTicket() function
    function burnTicket(uint256 ticketId) public onlyEventOrganizer {
        require(
            ownerOf(ticketId) == msg.sender,
            "Caller is not the ticket owner"
        );
        require(
            getTicketsAvailable(ticketId) > 0,
            "All tickets have been sold"
        );
        _burn(ticketId);
    }

    // Reference to the UserAccount contract
    UserAccount private _userAccount;
    // Counter to keep track of unique ticket IDs
    Counters.Counter private _ticketIdCounter;

    // Mappings to store ticket metadata
    mapping(uint256 => uint256) private _ticketPrices;
    mapping(uint256 => uint256) private _ticketEventIds;
    mapping(uint256 => uint256) private _ticketQuantities;
    mapping(uint256 => uint256) private _ticketsSold;

    // Event emitted when a new ticket is minted
    event TicketMinted(
        uint256 indexed ticketId,
        uint256 indexed eventId,
        address indexed owner,
        uint256 price,
        uint256 quantity
    );

    // Constructor initializes the contract with a reference to the EventManager contract
    constructor(address userAccountAddress) ERC721("TicketNFT", "TNFT") {
        _userAccount = UserAccount(userAccountAddress);
    }

    // Modifier to restrict certain actions to event organizers only
    modifier onlyEventOrganizer() {
        require(
            _userAccount.isEventOrganizer(msg.sender),
            "Caller is not an event organizer"
        );
        _;
    }

    // Function to mint a new ticket for an event
    function mintTicket(
        uint256 eventId,
        uint256 price,
        string memory tokenURI,
        uint256 quantity
    ) public onlyEventOrganizer {
        _ticketIdCounter.increment();

        uint256 ticketId = _ticketIdCounter.current();

        _mint(msg.sender, ticketId);
        _setTokenURI(ticketId, tokenURI);

        // Update the _organizerEvents mapping
        _organizerEvents[msg.sender].push(eventId);

        _ticketPrices[ticketId] = price;
        _ticketEventIds[ticketId] = eventId;
        _ticketQuantities[ticketId] = quantity;
        _ticketsSold[ticketId] = 0;

        emit TicketMinted(ticketId, eventId, msg.sender, price, quantity);
    }

    // Function to purchase a ticket
    function purchaseTicket(uint256 ticketId) public payable {
        uint256 price = _ticketPrices[ticketId];
        address ticketOwner = ownerOf(ticketId);
        uint256 availableTickets = _ticketQuantities[ticketId] -
            _ticketsSold[ticketId];
        require(
            availableTickets > 0,
            "No more tickets available for this event"
        );
        require(msg.value == price, "Incorrect Ether value sent");

        payable(ticketOwner).transfer(msg.value);

        _ticketsSold[ticketId] += 1;
        _safeTransfer(ticketOwner, msg.sender, ticketId, "");
    }

    // Add a function to get the list of event IDs for a specific organizer
    function getOrganizerEvents(
        address organizer
    ) public view returns (uint256[] memory) {
        return _organizerEvents[organizer];
    }

    // Function for event organizers to withdraw funds from ticket sales
    function withdrawFunds(uint256 ticketId) public onlyEventOrganizer {
        address payable ticketOwner = payable(ownerOf(ticketId));
        uint256 amountToWithdraw = _ticketsSold[ticketId] *
            _ticketPrices[ticketId];

        ticketOwner.transfer(amountToWithdraw);
        _ticketsSold[ticketId] = 0;
    }

    // Getter functions for ticket metadata
    function getTicketPrice(uint256 ticketId) public view returns (uint256) {
        return _ticketPrices[ticketId];
    }

    function getTicketEventId(uint256 ticketId) public view returns (uint256) {
        return _ticketEventIds[ticketId];
    }

    function getTicketQuantity(uint256 ticketId) public view returns (uint256) {
        return _ticketQuantities[ticketId];
    }

    function getTicketsSold(uint256 ticketId) public view returns (uint256) {
        return _ticketsSold[ticketId];
    }

    // Function to get the number of available tickets for a given ticket ID
    function getTicketsAvailable(
        uint256 ticketId
    ) public view returns (uint256) {
        return _ticketQuantities[ticketId] - _ticketsSold[ticketId];
    }
}
