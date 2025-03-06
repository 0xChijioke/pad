// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVesting {
    /// @notice Different types of vesting schedules.
    /// DISCRETE: Periodic releases.
    /// CONTINUOUS: Real-time streaming.
    /// CUSTOM: For any other type defined later.
    enum VestingType { DISCRETE, CONTINUOUS, CUSTOM }

    /**
     * @notice Configures a vesting schedule for a recipient with common parameters and extra data for type-specific settings.
     * @param recipient The address receiving the vested tokens.
     * @param vestingId Unique identifier for this vesting schedule.
     * @param totalAmount Total tokens to vest.
     * @param startTime Timestamp when vesting begins.
     * @param duration Total duration of vesting in seconds.
     * @param cliffDuration Seconds before any vesting occurs (0 for no cliff).
     * @param vestingType The type of vesting schedule (DISCRETE, CONTINUOUS).
     * @param extraData Encoded type-specific parameters (e.g., for DISCRETE, it could be the interval between releases; for CONTINUOUS, it could be the flow rate;).
     */
    function configureVesting(
        address recipient,
        bytes32 vestingId,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration,
        uint256 cliffDuration,
        VestingType vestingType,
        bytes calldata extraData
    ) external;

    /**
     * @notice Releases vested tokens for a specific vesting schedule.
     * @param recipient The address to release tokens for.
     * @param vestingId The vesting schedule identifier.
     * @return amountReleased The amount of tokens released.
     */
    function release(address recipient, bytes32 vestingId) external returns (uint256 amountReleased);

    /**
     * @notice Returns the amount vested so far for a specific vesting schedule.
     * @param recipient The address to query.
     * @param vestingId The vesting schedule identifier.
     * @return The vested token amount.
     */
    function getVestedAmount(address recipient, bytes32 vestingId) external view returns (uint256);

    /**
     * @notice Checks if vesting is complete for a specific schedule.
     * @param recipient The address to check.
     * @param vestingId The vesting schedule identifier.
     * @return True if vesting is complete, false otherwise.
     */
    function isVestingComplete(address recipient, bytes32 vestingId) external view returns (bool);

    /**
     * @notice Stops a vesting schedule (e.g., halts streaming or cancels discrete vesting).
     * @param recipient The address whose vesting to stop.
     * @param vestingId The vesting schedule identifier.
     */
    function stopVesting(address recipient, bytes32 vestingId) external;

    /**
     * @notice Gets detailed information about a specific vesting schedule.
     * @param recipient The address to query.
     * @param vestingId The vesting schedule identifier.
     * @return vestingType The type of vesting.
     * @return totalAmount Total tokens to vest.
     * @return vestedAmount Tokens vested so far.
     * @return remainingAmount Tokens still to be vested.
     * @return startTime Timestamp when vesting began.
     * @return endTime Timestamp when vesting ends.
     * @return extraData The type-specific configuration parameters.
     */
    function getVestingDetails(address recipient, bytes32 vestingId)
        external
        view
        returns (
            VestingType vestingType,
            uint256 totalAmount,
            uint256 vestedAmount,
            uint256 remainingAmount,
            uint256 startTime,
            uint256 endTime,
            bytes memory extraData
        );

    /// Emitted when a vesting schedule is configured.
    event VestingConfigured(
        address indexed recipient,
        bytes32 indexed vestingId,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration,
        VestingType vestingType
    );

    /// Emitted when tokens are released or streaming starts/stops.
    event TokensReleased(address indexed recipient, bytes32 indexed vestingId, uint256 amount);

    /// Emitted when vesting is stopped.
    event VestingStopped(address indexed recipient, bytes32 indexed vestingId);
}
