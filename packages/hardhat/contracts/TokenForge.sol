// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenForge {
    struct TokenInfo {
        address creator;
        string name;
        string symbol;
        uint256 totalSupply;
        address[] modules;
    }

    // Mapping from token address to its info
    mapping(address => TokenInfo) public tokens;

    // Events for logging key actions
    event TokenRegistered(
        address indexed token,
        address indexed creator,
        string name,
        string symbol,
        uint256 totalSupply
    );
    event ModuleAdded(address indexed token, address indexed module);

    /**
     * @notice Registers a new token with its basic information.
     * @dev This function is intended to be called only by the factory.
     * @param token The address of the deployed token.
     * @param creator The address that created the token.
     * @param name The token's name.
     * @param symbol The token's symbol.
     * @param totalSupply The total supply of the token.
     */
    function registerToken(
        address token,
        address creator,
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) public {
        require(tokens[token].creator == address(0), "Token already registered");
        tokens[token] = TokenInfo({
            creator: creator,
            name: name,
            symbol: symbol,
            totalSupply: totalSupply,
            modules: new address[](0)
        });
        emit TokenRegistered(token, creator, name, symbol, totalSupply);
    }

    /**
     * @notice Adds a module to an already registered token.
     * @dev Implement, access control to restrict this action.
     * @param token The token address to update.
     * @param moduleAddress The address of the module to attach.
     */
    function addModule(address token, address moduleAddress) public {
        require(tokens[token].creator != address(0), "Token not registered");
        tokens[token].modules.push(moduleAddress);
        emit ModuleAdded(token, moduleAddress);
    }

    /**
     * @notice Returns the list of modules attached to a given token.
     * @param token The token address.
     * @return An array of module addresses.
     */
    function getModules(address token) public view returns (address[] memory) {
        return tokens[token].modules;
    }
}
