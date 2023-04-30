// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// This import is for restrict access to certain functions or actions with smart contract based on roles
import "@openzeppelin/contracts/access/AccessControl.sol";
// This import is for manage unique identifiers for events and tickets
import "@openzeppelin/contracts/utils/Counters.sol";

// UserAccount smart contract that manages account creation, authentication, and user profile management
contract UserAccount is AccessControl {
    using Counters for Counters.Counter;

    // Counter for user IDs
    Counters.Counter private _userIds;

    // Define roles for event organizers and ticket users
    bytes32 public constant EVENT_ORGANIZER_ROLE =
        keccak256("EVENT_ORGANIZER_ROLE");
    bytes32 public constant TICKET_USER_ROLE = keccak256("TICKET_USER_ROLE");

    // Addresses of the EventManager and TicketNFT contracts
    address private _eventManagerAddress;
    address private _ticketNFTAddress;

    // UserProfile: store user information
    struct UserProfile {
        uint256 id;
        string name;
        string email;
        address userAddress;
    }

    // Mapping to store user profiles by user ID
    mapping(uint256 => UserProfile) private _userProfiles;
    // Mapping to store user IDs by Ethereum address
    mapping(address => uint256) private _addressToUserId;

    // Event emitted when a new user is registered
    event NewUser(
        uint256 indexed userId,
        string name,
        string email,
        address userAddress
    );

    // Constructor to set up the admin role
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Function to set the address of the EventManager contract
    function setEventManagerAddress(
        address eventManagerAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _eventManagerAddress = eventManagerAddress;
    }

    // Function to set the address of the TicketNFT contract
    function setTicketNFTAddress(
        address ticketNFTAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _ticketNFTAddress = ticketNFTAddress;
    }

    // Function to register a new user
    function registerUser(
        string memory name,
        string memory email,
        bool organizerRole
    ) public {
        // Check if the user is already registered
        require(_addressToUserId[msg.sender] == 0, "User already registered");

        // Increment the user ID counter
        _userIds.increment();
        uint256 newUserId = _userIds.current();

        // Create a new UserProfile and store it in the mapping
        UserProfile storage newUserProfile = _userProfiles[newUserId];
        newUserProfile.id = newUserId;
        newUserProfile.name = name;
        newUserProfile.email = email;
        newUserProfile.userAddress = msg.sender;

        // Store the user ID by Ethereum address
        _addressToUserId[msg.sender] = newUserId;

        // Grant the user the appropriate role
        if (organizerRole) {
            grantRole(EVENT_ORGANIZER_ROLE, msg.sender);
        } else {
            grantRole(TICKET_USER_ROLE, msg.sender);
        }

        // Emit the NewUser event
        emit NewUser(newUserId, name, email, msg.sender);
    }

    // Function to get user profile by user ID
    function getUserProfile(
        uint256 userId
    ) public view returns (UserProfile memory) {
        return _userProfiles[userId];
    }

    // Function to get a user profile by Ethereum address
    function getUserProfileByAddress(
        address userAddress
    ) public view returns (UserProfile memory) {
        uint256 userId = _addressToUserId[userAddress];
        return getUserProfile(userId);
    }

    // Function to check if an Ethereum address has the event organizer role
    function isEventOrganizer(address userAddress) public view returns (bool) {
        return hasRole(EVENT_ORGANIZER_ROLE, userAddress);
    }

    // Function to check if an Ethereum address has the ticket user role
    function isTicketUser(address userAddress) public view returns (bool) {
        return hasRole(TICKET_USER_ROLE, userAddress);
    }

    // Function to update a user's profile information
    function updateUserProfile(
        uint256 userId,
        string memory name,
        string memory email
    ) public {
        // Check if the user exists
        require(_addressToUserId[msg.sender] == userId, "User not found");
        UserProfile storage user = _userProfiles[userId];

        // Update the user's name and email
        user.name = name;
        user.email = email;
    }

    // Function to switch a user's role
    function switchUserRole(bool organizerRole) public {
        if (organizerRole) {
            revokeRole(TICKET_USER_ROLE, msg.sender);
            grantRole(EVENT_ORGANIZER_ROLE, msg.sender);
        } else {
            revokeRole(EVENT_ORGANIZER_ROLE, msg.sender);
            grantRole(TICKET_USER_ROLE, msg.sender);
        }
    }
}
