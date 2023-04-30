// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./UserAccount.sol";

// EventManager smart contract that manages event creation, editing, and deleting
contract EventManager {
    // Reference to the UserAccount smart contract
    UserAccount private _userAccount;

    // Counter for event IDs
    uint256 private _eventIdCounter;

    // EventDetails: store event information
    struct EventDetails {
        uint256 id;
        string name;
        string description;
        uint256 date;
        string location;
        address organizer;
    }

    // Mapping to store event details by event ID
    mapping(uint256 => EventDetails) private _events;
    // Mapping to store event IDs by event organizer address
    mapping(address => uint256[]) private _organizerEvents;

    // Event emitted when a new event is created
    event NewEvent(
        uint256 indexed eventId,
        string name,
        string description,
        uint256 date,
        string location,
        address organizer
    );

    // Constructor to set the address of the UserAccount contract
    constructor(address UserAccountAddress) {
        _userAccount = UserAccount(UserAccountAddress);
    }

    // Modifier to check if the caller is an event organizer
    modifier onlyEventOrganizer() {
        require(
            _userAccount.isEventOrganizer(msg.sender),
            "Caller is not an event organizer"
        );
        _;
    }

    // Function to create a new event
    function createEvent(
        string memory name,
        string memory description,
        uint256 date,
        string memory location
    ) public onlyEventOrganizer {
        // Increment the event ID counter
        _eventIdCounter++;

        // Create a new EventDetails struct and store it in the mapping
        EventDetails storage newEvent = _events[_eventIdCounter];
        newEvent.id = _eventIdCounter;
        newEvent.name = name;
        newEvent.description = description;
        newEvent.date = date;
        newEvent.location = location;
        newEvent.organizer = msg.sender;

        // Add the event ID to the organizer's list of events
        _organizerEvents[msg.sender].push(_eventIdCounter);

        // Emit the NewEvent event
        emit NewEvent(
            _eventIdCounter,
            name,
            description,
            date,
            location,
            msg.sender
        );
    }

    // Function to edit an existing event
    function editEvent(
        uint256 eventId,
        string memory name,
        string memory description,
        uint256 date,
        string memory location
    ) public onlyEventOrganizer {
        // Check if the event exists and the caller is the organizer
        EventDetails storage eventToUpdate = _events[eventId];
        require(
            eventToUpdate.organizer == msg.sender,
            "Caller is not the event organizer"
        );

        // Update the event details
        eventToUpdate.name = name;
        eventToUpdate.description = description;
        eventToUpdate.date = date;
        eventToUpdate.location = location;
    }

    // Function to delete an existing event
    function deleteEvent(uint256 eventId) public onlyEventOrganizer {
        // Check if the event exists and the caller is the organizer
        EventDetails storage eventToDelete = _events[eventId];
        require(
            eventToDelete.organizer == msg.sender,
            "Caller is not the event organizer"
        );

        // Delete the event from the mapping
        delete _events[eventId];

        // Remove the event ID from the organizer's list of events
        uint256[] storage organizerEventIds = _organizerEvents[msg.sender];
                for (uint256 i = 0; i < organizerEventIds.length; i++) {
            if (organizerEventIds[i] == eventId) {
                organizerEventIds[i] = organizerEventIds[
                    organizerEventIds.length - 1
                ];
                organizerEventIds.pop();
                break;
            }
        }
    }

// Get the list of event details for a specific organizer
function getOrganizerEventDetails(address organizer) public view returns (EventDetails[] memory) {
    uint256[] memory eventIds = _organizerEvents[organizer];
    EventDetails[] memory events = new EventDetails[](eventIds.length);
    
    for (uint256 i = 0; i < eventIds.length; i++) {
        events[i] = _events[eventIds[i]];
    }
    
    return events;
}

function totalEvents() public view returns (uint256) {
    return _eventIdCounter;
}

    // Function to get an event's details by event ID
    function getEvent(
        uint256 eventId
    ) public view returns (EventDetails memory) {
        return _events[eventId];
    }

    // Function to get an event organizer's list of event IDs
    function getOrganizerEvents(
        address organizer
    ) public view returns (uint256[] memory) {
        return _organizerEvents[organizer];
    }

    // Function to get the list of all event IDs
    function getAllEventIds() public view returns (uint256[] memory) {
        uint256[] memory eventIds = new uint256[](_eventIdCounter);
        for (uint256 i = 1; i <= _eventIdCounter; i++) {
            eventIds[i - 1] = i;
        }
        return eventIds;
    }



}
