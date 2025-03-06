// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVesting {
    /// @notice Configures a vesting schedule for a recipient.
    /// @param recipient The address receiving the vested tokens.
    /// @param vestingId Unique identifier for this vesting schedule.
    /// @param totalAmount Total tokens to vest.
    /// @param startTime When vesting begins (timestamp).
    /// @param duration Total duration of vesting in seconds.
    /// @param cliffDuration Seconds before any vesting occurs (0 for no cliff).
    /// @param vestingType DISCRETE (periodic releases) or CONTINUOUS (streaming).
    /// @param interval For DISCRETE: seconds between releases; ignored for CONTINUOUS.
    /// @param flowRate For CONTINUOUS: tokens per second; ignored for DISCRETE.
    function configureVesting(
        address recipient,
        bytes32 vestingId,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration,
        uint256 cliffDuration,
        VestingType vestingType,
        uint256 interval,
        uint256 flowRate
    ) external;

    /// @notice Releases vested tokens for a specific vesting schedule.
    /// @param recipient The address to release tokens for.
    /// @param vestingId The vesting schedule to release from.
    /// @return amountReleased The amount of tokens released or streamed.
    function release(address recipient, bytes32 vestingId) external returns (uint256 amountReleased);

    /// @notice Returns the amount vested so far for a specific vesting schedule.
    /// @param recipient The address to query.
    /// @param vestingId The vesting schedule to query.
    /// @return The vested amount.
    function getVestedAmount(address recipient, bytes32 vestingId) external view returns (uint256);

    /// @notice Checks if vesting is complete for a specific schedule.
    /// @param recipient The address to check.
    /// @param vestingId The vesting schedule to check.
    /// @return True if vesting is complete, false otherwise.
    function isVestingComplete(address recipient, bytes32 vestingId) external view returns (bool);

    /// @notice Stops a vesting schedule (e.g., halts streaming or cancels discrete vesting).
    /// @param recipient The address whose vesting to stop.
    /// @param vestingId The vesting schedule to stop.
    function stopVesting(address recipient, bytes32 vestingId) external;

    /// @notice Get vesting details for a specific schedule.
    /// @param recipient The address to query.
    /// @param vestingId The vesting schedule to query.
    /// @return vestingType The type of vesting (DISCRETE or CONTINUOUS).
    /// @return totalAmount The total amount of tokens to vest.
    /// @return vestedAmount The amount of tokens vested so far.
    /// @return remainingAmount The amount of tokens still to be vested.
    /// @return startTime The timestamp when vesting begins.
    /// @return endTime The timestamp when vesting ends.
    function getVestingDetails(address recipient, bytes32 vestingId) external view returns (
        VestingType vestingType,
        uint256 totalAmount,
        uint256 vestedAmount,
        uint256 remainingAmount,
        uint256 startTime,
        uint256 endTime
    );

    /// @notice Emitted when a vesting schedule is configured.
    event VestingConfigured(
        address indexed recipient,
        bytes32 indexed vestingId,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration,
        VestingType vestingType
    );

    /// @notice Emitted when tokens are released or streaming starts/stops.
    event TokensReleased(address indexed recipient, bytes32 indexed vestingId, uint256 amount);

    /// @notice Emitted when vesting is stopped.
    event VestingStopped(address indexed recipient, bytes32 indexed vestingId);

    enum VestingType { DISCRETE, CONTINUOUS }
}