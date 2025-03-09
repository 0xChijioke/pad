// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

import { IVesting } from "./IVesting.sol";

/**
 * @title VestingManager
 * @notice Manages vesting schedules for tokens.
 *         Allows adding, updating, and removing vesting schedules for beneficiaries.
 *         Supports multiple vesting schedules per token/beneficiary.
 */
contract VestingManager is AccessControl {

    bytes32 public constant VESTING_ADMIN = keccak256("VESTING_ADMIN");




/// @notice Enumeration for the vesting options.
    enum VestingType {
    
}


    
    event VestingScheduleAdded(
        address indexed token,
        address indexed beneficiary,
        IVesting.VestingType vestingType
    );
    event VestingScheduleRemoved(
        address indexed token,
        address indexed beneficiary,
        IVesting.VestingType vestingType
    );



    /**
     * @notice Adds a new vesting schedule for a beneficiary.
     * @param token The address of the token (registered via TokenForge).
     * @param beneficiary The beneficiary receiving vested tokens.
     * @param vestingType The type of vesting (e.g., Superfluid or Discrete).
     */
     function addVestingSchedule(
        address token,
        address beneficiary,
        IVesting.VestingType vestingType
    ) external onlyRole(VESTING_ADMIN) {
        
        emit VestingScheduleAdded(token, beneficiary, vestingType);
    }

    /**
     * @notice Removes an existing vesting schedule for a beneficiary.
     * @param token The address of the token.
     * @param beneficiary The beneficiary whose vesting schedule is being removed.
     * @param index The index of the vesting schedule to remove.
     */
    function removeVestingSchedule(
        address token,
        address beneficiary,
        uint256 index
    ) external onlyRole(VESTING_ADMIN) {
        
        emit VestingScheduleRemoved(token, beneficiary, removedSchedule.vestingType);
    }

}