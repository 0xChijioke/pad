// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Token.sol";

/**
 * @title TokenForge
 * @notice Central hub for token creation, registration, and strategy management, designed for modularity and scalability.
 * @dev Uses UUPS upgradeable pattern and AccessControl for secure role-based management.
 */
contract TokenForge is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    // Roles for access control
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    // Struct to store token metadata and strategies
    struct TokenInfo {
        address registrant; // Address that registered or created the token
        mapping(string => address[]) strategies; // Maps strategy types to an array of strategy contract addresses
    }

    // Mappings for token tracking
    mapping(address => TokenInfo) private _tokens; // Token address to its info
    mapping(address => bool) public isRegistered; // Tracks registered tokens

    // Events for off-chain tracking and transparency
    event TokenCreated(address indexed token, address indexed owner, uint256 initialSupply);
    event TokenRegistered(address indexed token, address indexed registrant);
    event StrategyAdded(address indexed token, address indexed strategy, string strategyType);
    event StrategyRemoved(address indexed token, address indexed strategy, string strategyType);

    /**
     * @notice Initializes the contract with admin roles
     * @dev Sets up roles and initializes OpenZeppelin libraries
     */
    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(TOKEN_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Creates a new token and registers it
     * @param initialOwner Address to receive the initial supply
     * @param initialSupply Initial token supply
     * @param name Token name
     * @param symbol Token symbol
     * @return Address of the newly created token
     */
    function createToken(
        address initialOwner,
        uint256 initialSupply,
        string memory name,
        string memory symbol
    ) public onlyRole(TOKEN_ADMIN_ROLE) returns (address) {
        require(initialOwner != address(0), "Invalid owner address");
        Token newToken = new Token(initialOwner, initialSupply, name, symbol);
        address tokenAddress = address(newToken);

        _registerToken(tokenAddress, msg.sender);
        emit TokenCreated(tokenAddress, initialOwner, initialSupply);
        return tokenAddress;
    }

    /**
     * @notice Registers an existing ERC-20 token
     * @param token Address of the token to register
     */
    function registerExistingToken(address token) public {
        require(token != address(0), "Invalid token address");
        require(!isRegistered[token], "Token already registered");
        _registerToken(token, msg.sender);
    }

    /**
     * @dev Internal function to register a token
     * @param token Token address
     * @param registrant Address registering the token
     */
    function _registerToken(address token, address registrant) internal {
        _tokens[token].registrant = registrant;
        isRegistered[token] = true;
        emit TokenRegistered(token, registrant);
    }

    /**
     * @notice Adds a strategy to a registered token
     * @param token Token address
     * @param strategyType Type of strategy
     * @param strategyAddress Address of the strategy contract
     */
    function addStrategy(
        address token,
        string memory strategyType,
        address strategyAddress
    ) public {
        require(isRegistered[token], "Token not registered");
        require(_tokens[token].registrant == msg.sender, "Only registrant can add strategies");
        require(strategyAddress != address(0), "Invalid strategy address");

        _tokens[token].strategies[strategyType].push(strategyAddress);
        emit StrategyAdded(token, strategyAddress, strategyType);
    }

    /**
     * @notice Removes a strategy from a registered token
     * @param token Token address
     * @param strategyType Type of strategy
     * @param strategyAddress Address of the strategy to remove
     */
    function removeStrategy(
        address token,
        string memory strategyType,
        address strategyAddress
    ) public {
        require(isRegistered[token], "Token not registered");
        require(_tokens[token].registrant == msg.sender, "Only registrant can remove strategies");

        address[] storage strategies = _tokens[token].strategies[strategyType];
        for (uint256 i = 0; i < strategies.length; i++) {
            if (strategies[i] == strategyAddress) {
                strategies[i] = strategies[strategies.length - 1];
                strategies.pop();
                emit StrategyRemoved(token, strategyAddress, strategyType);
                return;
            }
        }
        revert("Strategy not found");
    }

    /**
     * @notice Retrieves all strategies of a given type for a token
     * @param token Token address
     * @param strategyType Strategy type
     * @return Array of strategy contract addresses
     */
    function getStrategies(
        address token,
        string memory strategyType
    ) public view returns (address[] memory) {
        return _tokens[token].strategies[strategyType];
    }

    /**
     * @notice Fetches the token’s name from its contract
     * @param token Token address
     * @return Token name
     */
    function getTokenName(address token) public view returns (string memory) {
        return ERC20(token).name();
    }

    /**
     * @notice Fetches the token’s symbol from its contract
     * @param token Token address
     * @return Token symbol
     */
    function getTokenSymbol(address token) public view returns (string memory) {
        return ERC20(token).symbol();
    }

    /**
     * @notice Fetches the token’s total supply from its contract
     * @param token Token address
     * @return Total supply
     */
    function getTokenTotalSupply(address token) public view returns (uint256) {
        return ERC20(token).totalSupply();
    }

    /**
     * @notice Gets the registrant of a token
     * @param token Token address
     * @return Registrant address
     */
    function getRegistrant(address token) public view returns (address) {
        return _tokens[token].registrant;
    }

    /**
     * @dev Restricts upgrades to UPGRADER_ROLE
     */
    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    /**
     * @dev Supports receiving ETH for fees or other purposes
     */
    receive() external payable {}
}