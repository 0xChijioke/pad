// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IVesting } from "./IVesting.sol";

// Import Superfluid interfaces
import { ISuperfluid, ISuperToken, IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

contract SuperfluidVesting is IVesting {
    /// @notice Superfluid protocol host contract.
    ISuperfluid private _host;
    /// @notice Constant Flow Agreement (CFA) interface.
    IConstantFlowAgreementV1 private _cfa;
    /// @notice The SuperToken to be streamed.
    ISuperToken public superToken;


    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VESTING_MANAGER_ROLE = keccak256("VESTING_MANAGER_ROLE");

    /// @notice Structure to track streaming vesting schedules.
    struct StreamSchedule {
        int96 flowRate;
        uint256 startTime;
        uint256 duration;
        uint256 remaining;
    }
    mapping(address => StreamSchedule) public streams;

    /// @dev Modifier to restrict function calls to only authorized contracts
    modifier onlyToken() {
        // implementation
        _;
    }

    constructor(
        ISuperfluid host,
        IConstantFlowAgreementV1 cfa,
        ISuperToken _superToken
    ) {
        _host = host;
        _cfa = cfa;
        superToken = _superToken;
    }

    /// @notice Starts a streaming vesting schedule for a recipient.
    /// @param recipient The address receiving the stream.
    /// @param flowRate The rate at which tokens are streamed (tokens per second).
    /// @param duration Duration of the stream in seconds.
    function startStream(address recipient, int96 flowRate, uint256 duration) external onlyToken {
        // Store the schedule – in a full implementation, calculate 'remaining' properly.
        streams[recipient] = StreamSchedule({
            flowRate: flowRate,
            startTime: block.timestamp,
            duration: duration,
            remaining: uint256(uint96(flowRate)) * duration
        });

        // call _host.callAgreement to create the flow.
    }

    /// @notice Stops the stream and removes vesting schedule.
    /// @param recipient The address whose stream is being stopped.
    function stopStream(address recipient) external onlyToken {
        // In a full implementation, call _host.callAgreement to delete the flow.
        delete streams[recipient];
    }

    /// @notice Returns current streaming vesting status for a recipient.
    function getStreamStatus(address recipient) external view returns (int96 flowRate, uint256 startTime, uint256 remaining) {
        StreamSchedule memory stream = streams[recipient];
        return (stream.flowRate, stream.startTime, stream.remaining);
    }

    // Additional functions
}
