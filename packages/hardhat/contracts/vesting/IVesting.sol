// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVesting {
    // Configure a vesting schedule for a recipient.
    function setVestingSchedule(
        address recipient,
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) external;

    // Releases the vested tokens.
    function release(address recipient) external;

    // Returns the total amount vested so far.
    function getVestedAmount(address recipient) external view returns (uint256);

}
