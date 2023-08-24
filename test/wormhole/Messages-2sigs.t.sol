// test/Messages.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;

import "../../src/apps/wormhole/external/wormhole/Messages.sol";
import "../../src/apps/wormhole/external/wormhole/Setters.sol";
import "../../src/apps/wormhole/external/wormhole/Structs.sol";
import { WormholeVerifier } from "../../src/apps/wormhole/external/callworm/WormholeVerifier.sol";
import { SmallStructs } from "../../src/apps/wormhole/external/callworm/SmallStructs.sol";
import "forge-std/Test.sol";

contract ExportedMessages is Messages, Setters {
    function storeGuardianSetPub(Structs.GuardianSet memory set, uint32 index) public {
        return super.storeGuardianSet(set, index);
    }
}

contract TestMessagesCopy2Sigs is Test {
  address constant testGuardianPub1 = 0xbeFA429d57cD18b7F8A4d91A2da9AB4AF05d0FBe;
  address testGuardianPub2;

  // A valid VM with one signature from the testGuardianPublic key
  bytes prevalidVM = hex"01000000000200867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d900";
  bytes postvalidVM = hex"000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa";
  bytes32 vmHash;
  bytes validVM;

  uint256 constant testGuardian1 = 93941733246223705020089879371323733820373732307041878556247502674739205313440;
  uint256 testGuardian2;

  ExportedMessages messages;

  WormholeVerifier messages2;

  Structs.GuardianSet guardianSet;

  function setUp() public {


    (testGuardianPub2, testGuardian2) = makeAddrAndKey("signer2");
    vmHash = keccak256(abi.encodePacked(keccak256(postvalidVM)));

    // Make validVM

    (uint8 v, bytes32 r,  bytes32 s) = vm.sign(testGuardian2, vmHash);

    validVM = abi.encodePacked(
      prevalidVM,
      uint8(1),
      r, s, v - 27,
      postvalidVM
    );

    messages = new ExportedMessages();

    messages2 = new WormholeVerifier(address(messages));

    // initialize guardian set with one guardian
    address[] memory keys = new address[](2);
    keys[0] = vm.addr(testGuardian1);
    keys[1] = vm.addr(testGuardian2);
    guardianSet = Structs.GuardianSet(keys, 0);
    require(messages.quorum(guardianSet.keys.length) == 2, "Quorum should be 2");
  }

  // This test checks the possibility of getting a unsigned message verified through verifyVM
  function test_compare_wormhole_implementation_and_calldata_version() public {
    // Set the initial guardian set
    address[] memory initialGuardians = new address[](2);
    initialGuardians[0] = testGuardianPub1;
    initialGuardians[1] = testGuardianPub2;

    // Create a guardian set
    Structs.GuardianSet memory initialGuardianSet = Structs.GuardianSet({
      keys: initialGuardians,
      expirationTime: 0
    });

    messages.storeGuardianSetPub(initialGuardianSet, uint32(0));

    // Confirm that the test VM is valid
    (Structs.VM memory parsedValidVm, bool valid, string memory reason) = messages.parseAndVerifyVM(validVM);
    (
      SmallStructs.SmallVM memory smallVM,
      bytes memory payload,
      bool valid2,
      string memory reason2
    ) = messages2.parseAndVerifyVM(validVM);
    
    require(valid, reason);
    assertEq(valid, true);
    assertEq(reason, "");

    assertEq(
      valid, valid2
    );
    assertEq(
      reason, reason2
    );

    assertEq(
      parsedValidVm.payload, payload, "payload"
    );
    assertEq(
      parsedValidVm.emitterChainId, smallVM.emitterChainId, "emitterChainId"
    );
    assertEq(
      parsedValidVm.emitterAddress, smallVM.emitterAddress, "emitterAddress"
    );
    assertEq(
      parsedValidVm.guardianSetIndex, smallVM.guardianSetIndex, "guardianSetIndex"
    );
  }

  function test_error_invalid_vm() public {
    // Set the initial guardian set
    address[] memory initialGuardians = new address[](2);
    initialGuardians[0] = testGuardianPub1;
    initialGuardians[1] = testGuardianPub2;

    // Create a guardian set
    Structs.GuardianSet memory initialGuardianSet = Structs.GuardianSet({
      keys: initialGuardians,
      expirationTime: 0
    });

    messages.storeGuardianSetPub(initialGuardianSet, uint32(0));
    bytes memory invalidVM = abi.encodePacked(validVM, uint8(1));

    // Confirm that the test VM is valid
    (Structs.VM memory parsedInValidVm, bool valid, string memory reason) = messages.parseAndVerifyVM(invalidVM);
    (
      SmallStructs.SmallVM memory smallVM,
      bytes memory payload,
      bool valid2,
      string memory reason2
    ) = messages2.parseAndVerifyVM(invalidVM);
    

    assertEq(
      valid, valid2
    );
    assertEq(
      reason, reason2
    );

    assertEq(valid2, false);
    assertEq(reason2, "VM signature invalid");
  }
}
