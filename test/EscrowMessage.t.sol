// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { TestCommon } from "./TestCommon.sol";

contract EscrowInformationTest is TestCommon {
    uint256 _overpay;

    function test_check_escrow_state() public {
        IncentiveDescription storage incentive = _INCENTIVE;
        (uint256 gasRefund, bytes32 messageIdentifier) = escrow.escrowMessage{value: incentive.totalIncentive}(
            bytes32(uint256(0x123123) + uint256(2**255)),
            _DESTINATION_ADDRESS_THIS,
            _MESSAGE,
            incentive
        );

        // Check that the message identifier points exposes the bounty.
        IncentiveDescription memory storedIncentiveAtEscrow = escrow.bounty(messageIdentifier);

        assertEq(incentive.minGasDelivery, storedIncentiveAtEscrow.minGasDelivery);
        assertEq(incentive.minGasAck, storedIncentiveAtEscrow.minGasAck);
        assertEq(incentive.totalIncentive, storedIncentiveAtEscrow.totalIncentive);
        assertEq(incentive.priceOfDeliveryGas, storedIncentiveAtEscrow.priceOfDeliveryGas);
        assertEq(incentive.priceOfAckGas, storedIncentiveAtEscrow.priceOfAckGas);
        assertEq(incentive.targetDelta, storedIncentiveAtEscrow.targetDelta);
    }

    function test_check_escrow_events() public {
        IncentiveDescription storage incentive = _INCENTIVE;

        vm.expectEmit();
        emit BountyPlaced(bytes32(0x561213edd20145c0e5b7e2f9303e83b75eb429046e9bddac10f0d8b1d53be42e), incentive);

        escrow.escrowMessage{value: incentive.totalIncentive}(
            bytes32(uint256(0x123123) + uint256(2**255)),
            _DESTINATION_ADDRESS_THIS,
            _MESSAGE,
            incentive
        );
    }

    function test_gas_refund(uint256 overpay) public {
        vm.assume(overpay < 10000 ether);

        IncentiveDescription storage incentive = _INCENTIVE;
        _overpay = overpay;

        
        (uint256 gasRefund, bytes32 messageIdentifier) = escrow.escrowMessage{value: incentive.totalIncentive + overpay}(
            bytes32(uint256(0x123123) + uint256(2**255)),
            _DESTINATION_ADDRESS_THIS,
            _MESSAGE,
            incentive
        );

        assertEq(gasRefund, overpay);
    }

    // test_gas_refund will end up calling this function.
    receive() payable external {
        assertNotEq(msg.value, 0);
        assertEq(msg.value, _overpay);
    }
}
