// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {PendingRoot, IUniversalRewardsDistributor} from "../src/interfaces/IUniversalRewardsDistributor.sol";

import {ErrorsLib} from "../src/libraries/ErrorsLib.sol";

import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";
import {UniversalRewardsDistributor} from "../src/UniversalRewardsDistributor.sol";
import {EventsLib} from "../src/libraries/EventsLib.sol";

import {Merkle} from "../lib/murky/src/Merkle.sol";
import "../lib/forge-std/src/Test.sol";

contract UniversalRewardsDistributorTest is Test {
    uint256 internal constant MAX_RECEIVERS = 20;
    bytes32 internal constant SALT = bytes32(0);

    Merkle merkle = new Merkle();
    ERC20Mock internal token1;
    ERC20Mock internal token2;
    IUniversalRewardsDistributor internal distributionWithoutTimeLock;
    IUniversalRewardsDistributor internal distributionWithTimeLock;
    address owner = _addrFromHashedString("Owner");
    address updater = _addrFromHashedString("Updater");

    bytes32 DEFAULT_ROOT = bytes32(keccak256(bytes("DEFAULT_ROOT")));
    bytes32 DEFAULT_IPFS_HASH = bytes32(keccak256(bytes("DEFAULT_IPFS_HASH")));
    uint256 DEFAULT_TIMELOCK = 1 days;

    function setUp() public {
        distributionWithoutTimeLock =
            IUniversalRewardsDistributor(address(new UniversalRewardsDistributor(owner, 0, bytes32(0), bytes32(0))));
        token1 = new ERC20Mock();
        token2 = new ERC20Mock();

        vm.startPrank(owner);
        distributionWithoutTimeLock.setRootUpdater(updater, true);

        vm.warp(block.timestamp + 1);
        distributionWithTimeLock = IUniversalRewardsDistributor(
            address(new UniversalRewardsDistributor(owner, DEFAULT_TIMELOCK, bytes32(0), bytes32(0)))
        );
        distributionWithTimeLock.setRootUpdater(updater, true);
        vm.stopPrank();

        token1.mint(owner, 1000 ether * 200);
        token2.mint(owner, 1000 ether * 200);

        token1.mint(address(distributionWithoutTimeLock), 1000 ether * 200);
        token2.mint(address(distributionWithoutTimeLock), 1000 ether * 200);
        token1.mint(address(distributionWithTimeLock), 1000 ether * 200);
        token2.mint(address(distributionWithTimeLock), 1000 ether * 200);
    }

    function testDistributionConstructor(address randomCreator) public {
        vm.prank(randomCreator);
        IUniversalRewardsDistributor distributor = IUniversalRewardsDistributor(
            address(new UniversalRewardsDistributor(randomCreator, DEFAULT_TIMELOCK, DEFAULT_ROOT, DEFAULT_IPFS_HASH))
        );

        PendingRoot memory pendingRoot = distributor.pendingRoot();
        assertEq(pendingRoot.root, bytes32(0));
        assertEq(pendingRoot.validAt, 0);
        assertEq(distributor.owner(), randomCreator);
        assertEq(distributor.timelock(), DEFAULT_TIMELOCK);
        assertEq(distributor.root(), DEFAULT_ROOT);
        assertEq(distributor.ipfsHash(), DEFAULT_IPFS_HASH);
    }

    function testDistributionConstructorEmitsOwnerSet(address randomCreator) public {
        bytes32 initCodeHash = hashInitCode(
            type(UniversalRewardsDistributor).creationCode,
            abi.encode(randomCreator, DEFAULT_TIMELOCK, DEFAULT_ROOT, DEFAULT_IPFS_HASH)
        );
        address urdAddress = computeCreate2Address(SALT, initCodeHash, address(randomCreator));

        vm.prank(randomCreator);
        vm.expectEmit(address(urdAddress));
        emit EventsLib.OwnerSet(randomCreator);
        new UniversalRewardsDistributor{salt: SALT}(randomCreator, DEFAULT_TIMELOCK, DEFAULT_ROOT, DEFAULT_IPFS_HASH);
    }

    function testDistributionConstructorEmitsRootSet(bytes32 randomRoot, bytes32 randomIpfsHash) public {
        bytes32 initCodeHash = hashInitCode(
            type(UniversalRewardsDistributor).creationCode,
            abi.encode(owner, DEFAULT_TIMELOCK, randomRoot, randomIpfsHash)
        );
        address urdAddress = computeCreate2Address(SALT, initCodeHash, owner);

        vm.prank(owner);
        vm.expectEmit(address(urdAddress));
        emit EventsLib.RootSet(randomRoot, randomIpfsHash);
        new UniversalRewardsDistributor{salt: SALT}(owner, DEFAULT_TIMELOCK, randomRoot, randomIpfsHash);
    }

    function testDistributionConstructorEmitsTimelockSet(uint256 timelock) public {
        bytes32 initCodeHash = hashInitCode(
            type(UniversalRewardsDistributor).creationCode, abi.encode(owner, timelock, DEFAULT_ROOT, DEFAULT_IPFS_HASH)
        );
        address urdAddress = computeCreate2Address(SALT, initCodeHash, owner);

        vm.prank(owner);
        vm.expectEmit(address(urdAddress));
        emit EventsLib.TimelockSet(timelock);
        new UniversalRewardsDistributor{salt: SALT}(owner, timelock, DEFAULT_ROOT, DEFAULT_IPFS_HASH);
    }

    function testSubmitRootWithoutTimelockAsRandomCallerShouldRevert(address randomCaller) public {
        vm.assume(!distributionWithoutTimeLock.isUpdater(randomCaller) && randomCaller != owner);

        vm.prank(randomCaller);
        vm.expectRevert(bytes(ErrorsLib.NOT_UPDATER_ROLE));
        distributionWithoutTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
    }

    function testSubmitRootWithPreviousPendingRootShouldRevert(bytes32 newRoot, bytes32 newIpfsHash) public {
        vm.assume(newRoot != distributionWithTimeLock.root() && newIpfsHash != distributionWithTimeLock.ipfsHash());

        vm.startPrank(owner);
        distributionWithTimeLock.submitRoot(newRoot, newIpfsHash);

        vm.expectRevert(bytes(ErrorsLib.ALREADY_PENDING));
        distributionWithTimeLock.submitRoot(newRoot, newIpfsHash);

        vm.stopPrank();
    }

    function testSubmitRootTwiceShouldWorkWhenModifyingIpfsHash(
        bytes32 newRoot,
        bytes32 newIpfsHash,
        bytes32 secondIpfsHash
    ) public {
        vm.assume(
            newRoot != distributionWithTimeLock.root() && newIpfsHash != distributionWithTimeLock.ipfsHash()
                && secondIpfsHash != newIpfsHash
        );

        vm.startPrank(owner);
        distributionWithTimeLock.setRoot(newRoot, newIpfsHash);

        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.PendingRootSet(owner, newRoot, secondIpfsHash);
        distributionWithTimeLock.submitRoot(newRoot, secondIpfsHash);
        vm.stopPrank();

        assertEq(distributionWithTimeLock.pendingRoot().ipfsHash, secondIpfsHash);
    }

    function testSubmitRootWithTimelockAsOwner() public {
        vm.prank(owner);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.PendingRootSet(owner, DEFAULT_ROOT, DEFAULT_IPFS_HASH);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        assert(distributionWithTimeLock.root() != DEFAULT_ROOT);

        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();
        assertEq(pendingRoot.root, DEFAULT_ROOT);
        assertEq(pendingRoot.ipfsHash, DEFAULT_IPFS_HASH);
        assertEq(pendingRoot.validAt, block.timestamp + DEFAULT_TIMELOCK);
    }

    function testSubmitRootWithTimelockAsUpdater() public {
        vm.prank(updater);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.PendingRootSet(updater, DEFAULT_ROOT, DEFAULT_IPFS_HASH);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        assert(distributionWithTimeLock.root() != DEFAULT_ROOT);

        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();
        assertEq(pendingRoot.root, DEFAULT_ROOT);
        assertEq(pendingRoot.ipfsHash, DEFAULT_IPFS_HASH);
        assertEq(pendingRoot.validAt, block.timestamp + DEFAULT_TIMELOCK);
    }

    function testSubmitRootWithTimelockAsRandomCallerShouldRevert(address randomCaller) public {
        vm.assume(!distributionWithTimeLock.isUpdater(randomCaller) && randomCaller != owner);

        vm.prank(randomCaller);
        vm.expectRevert(bytes(ErrorsLib.NOT_UPDATER_ROLE));
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
    }

    function testAcceptRootShouldUpdateMainRoot(address randomCaller) public {
        vm.prank(updater);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        assert(distributionWithTimeLock.root() != DEFAULT_ROOT);
        vm.warp(block.timestamp + 1 days);

        vm.prank(randomCaller);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.RootSet(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
        distributionWithTimeLock.acceptRoot();

        assertEq(distributionWithTimeLock.root(), DEFAULT_ROOT);
        assertEq(distributionWithTimeLock.ipfsHash(), DEFAULT_IPFS_HASH);
        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();
        assertEq(pendingRoot.root, bytes32(0));
        assertEq(pendingRoot.ipfsHash, bytes32(0));
        assertEq(pendingRoot.validAt, 0);
    }

    function testAcceptRootShouldRevertIfTimelockNotFinished(address randomCaller, uint256 timeElapsed) public {
        timeElapsed = bound(timeElapsed, 0, distributionWithTimeLock.timelock() - 1);

        vm.prank(updater);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        assert(distributionWithTimeLock.root() != DEFAULT_ROOT);

        vm.warp(block.timestamp + timeElapsed);

        vm.prank(randomCaller);
        vm.expectRevert(bytes(ErrorsLib.TIMELOCK_NOT_EXPIRED));
        distributionWithTimeLock.acceptRoot();
    }

    function testAcceptRootShouldRevertIfNoPendingRoot(address randomCaller) public {
        vm.prank(randomCaller);
        vm.expectRevert(bytes(ErrorsLib.NO_PENDING_ROOT));
        distributionWithTimeLock.acceptRoot();
    }

    function testSetRootWithoutTimelockAsRandomCallerShouldRevert(address randomCaller) public {
        vm.assume(!distributionWithoutTimeLock.isUpdater(randomCaller) && randomCaller != owner);

        vm.prank(randomCaller);
        vm.expectRevert(bytes(ErrorsLib.NOT_UPDATER_ROLE));
        distributionWithoutTimeLock.setRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
    }

    function testSetRootWithTimelockShouldRevertIfNotOwner(bytes32 newRoot, address randomCaller) public {
        vm.assume(randomCaller != owner);

        vm.prank(randomCaller);
        vm.expectRevert();
        distributionWithTimeLock.setRoot(newRoot, DEFAULT_IPFS_HASH);
    }

    function testSetRootWithPreviousRootShouldRevert(bytes32 newRoot, bytes32 newIpfsHash) public {
        vm.assume(newRoot != distributionWithTimeLock.root() && newIpfsHash != distributionWithTimeLock.ipfsHash());

        vm.startPrank(owner);
        distributionWithTimeLock.setRoot(newRoot, newIpfsHash);

        vm.expectRevert(bytes(ErrorsLib.ALREADY_SET));
        distributionWithTimeLock.setRoot(newRoot, newIpfsHash);

        vm.stopPrank();
    }

    function testSetRootShouldUpdateTheCurrentRoot(bytes32 newRoot, bytes32 newIpfsHash) public {
        vm.prank(owner);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.RootSet(newRoot, newIpfsHash);
        distributionWithTimeLock.setRoot(newRoot, newIpfsHash);

        assertEq(distributionWithTimeLock.root(), newRoot);
        assertEq(distributionWithTimeLock.ipfsHash(), newIpfsHash);

        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();

        assertEq(pendingRoot.root, bytes32(0));
        assertEq(pendingRoot.ipfsHash, bytes32(0));
        assertEq(pendingRoot.validAt, 0);
    }

    function testSetRootWithoutTimelockAsUpdater() public {
        vm.prank(updater);
        vm.expectEmit(address(distributionWithoutTimeLock));
        emit EventsLib.RootSet(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
        distributionWithoutTimeLock.setRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        assertEq(distributionWithoutTimeLock.root(), DEFAULT_ROOT);
        assertEq(distributionWithoutTimeLock.ipfsHash(), DEFAULT_IPFS_HASH);
        PendingRoot memory pendingRoot = distributionWithoutTimeLock.pendingRoot();
        assertEq(pendingRoot.root, bytes32(0));
        assertEq(pendingRoot.validAt, 0);
        assertEq(pendingRoot.ipfsHash, bytes32(0));
    }

    function testSetRootShouldUpdateTheCurrentPendingRoot(bytes32 newRoot, bytes32 newIpfsHash) public {
        vm.prank(updater);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        vm.prank(owner);
        distributionWithTimeLock.setRoot(newRoot, newIpfsHash);

        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();

        assertEq(pendingRoot.validAt, 0);
        assertEq(pendingRoot.root, 0);
        assertEq(pendingRoot.ipfsHash, 0);
    }

    function testSetTimelockShouldChangeTheTimelock(uint256 newTimelock) public {
        newTimelock = bound(newTimelock, 0, type(uint256).max);

        vm.assume(newTimelock != distributionWithoutTimeLock.timelock());

        vm.prank(owner);
        vm.expectEmit(address(distributionWithoutTimeLock));
        emit EventsLib.TimelockSet(newTimelock);
        distributionWithoutTimeLock.setTimelock(newTimelock);

        assertEq(distributionWithoutTimeLock.timelock(), newTimelock);
    }

    function testSetTimelockShouldRevertIfSameValue(uint256 newTimelock) public {
        newTimelock = bound(newTimelock, 0, type(uint256).max);

        vm.assume(newTimelock != distributionWithoutTimeLock.timelock());

        vm.prank(owner);
        distributionWithoutTimeLock.setTimelock(newTimelock);

        vm.prank(owner);
        vm.expectRevert(bytes(ErrorsLib.ALREADY_SET));
        distributionWithoutTimeLock.setTimelock(newTimelock);
    }

    function testSetTimelockShouldRevertIfNotOwner(uint256 newTimelock, address randomCaller) public {
        vm.assume(randomCaller != owner);
        newTimelock = bound(newTimelock, 0, type(uint256).max);

        vm.prank(randomCaller);
        vm.expectRevert(bytes(ErrorsLib.NOT_OWNER));
        distributionWithoutTimeLock.setTimelock(newTimelock);
    }

    function testSetTimelockShouldNotImpactPendingValuesIfTimelockIncreased(uint256 timeElapsed, uint256 newTimelock)
        public
    {
        newTimelock = bound(newTimelock, DEFAULT_TIMELOCK + 1, type(uint256).max - block.timestamp);
        vm.assume(timeElapsed > DEFAULT_TIMELOCK && timeElapsed <= newTimelock);

        vm.prank(updater);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        vm.prank(owner);
        distributionWithTimeLock.setTimelock(newTimelock);

        assertEq(distributionWithTimeLock.timelock(), newTimelock);

        vm.warp(block.timestamp + timeElapsed);

        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.RootSet(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
        distributionWithTimeLock.acceptRoot();
    }

    function testSetTimelockShouldNotImpactPendingValuesIfTimelockReduced(uint256 timeElapsed, uint256 newTimelock)
        public
    {
        vm.assume(newTimelock > 0);
        timeElapsed = bound(timeElapsed, 1, DEFAULT_TIMELOCK - 1);
        newTimelock = bound(newTimelock, 0, timeElapsed - 1);

        vm.prank(owner);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        vm.warp(block.timestamp + timeElapsed);

        vm.prank(owner);
        distributionWithTimeLock.setTimelock(newTimelock);

        // Here, we are between the old and the new timelock.
        vm.expectRevert(bytes(ErrorsLib.TIMELOCK_NOT_EXPIRED));
        distributionWithTimeLock.acceptRoot();

        vm.warp(block.timestamp + DEFAULT_TIMELOCK - timeElapsed);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.RootSet(DEFAULT_ROOT, DEFAULT_IPFS_HASH);
        distributionWithTimeLock.acceptRoot();
    }

    function testSetTimelockShouldWorkIfPendingRootIsUpdatableButNotYetUpdated() public {
        vm.prank(owner);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        vm.warp(block.timestamp + DEFAULT_TIMELOCK);

        vm.prank(owner);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.TimelockSet(0.7 days);
        distributionWithTimeLock.setTimelock(0.7 days);

        assertEq(distributionWithTimeLock.timelock(), 0.7 days);
    }

    function testSetRootUpdaterShouldAddOrRemoveRootUpdater(address newUpdater, bool active) public {
        vm.assume(distributionWithoutTimeLock.isUpdater(newUpdater) != active);

        vm.prank(owner);
        vm.expectEmit(address(distributionWithoutTimeLock));
        emit EventsLib.RootUpdaterSet(newUpdater, active);
        distributionWithoutTimeLock.setRootUpdater(newUpdater, active);

        assertEq(distributionWithoutTimeLock.isUpdater(newUpdater), active);
    }

    function testSetRootUpdaterShouldRevertIfAlreadySet(address newUpdater, bool active) public {
        vm.assume(distributionWithoutTimeLock.isUpdater(newUpdater) != active);

        vm.prank(owner);
        distributionWithoutTimeLock.setRootUpdater(newUpdater, active);

        vm.prank(owner);
        vm.expectRevert(bytes(ErrorsLib.ALREADY_SET));
        distributionWithoutTimeLock.setRootUpdater(newUpdater, active);
    }

    function testSetRootUpdaterShouldRevertIfNotOwner(address caller, bool active) public {
        vm.assume(caller != owner);

        vm.prank(caller);
        vm.expectRevert(bytes(ErrorsLib.NOT_OWNER));
        distributionWithoutTimeLock.setRootUpdater(_addrFromHashedString("RANDOM_UPDATER"), active);
    }

    function testRevokePendingRootShouldRevokeWhenCalledWithOwner() public {
        vm.prank(owner);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        vm.prank(owner);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.PendingRootRevoked(owner);
        distributionWithTimeLock.revokePendingRoot();

        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();
        assertEq(pendingRoot.root, bytes32(0));
        assertEq(pendingRoot.validAt, 0);
    }

    function testRevokePendingRootShouldRevokeWhenCalledWithUpdater() public {
        vm.prank(owner);
        distributionWithTimeLock.submitRoot(DEFAULT_ROOT, DEFAULT_IPFS_HASH);

        vm.prank(updater);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.PendingRootRevoked(updater);
        distributionWithTimeLock.revokePendingRoot();

        PendingRoot memory pendingRoot = distributionWithTimeLock.pendingRoot();
        assertEq(pendingRoot.root, bytes32(0));
        assertEq(pendingRoot.validAt, 0);
    }

    function testRevokePendingRootShouldRevertIfNotUpdater(bytes32 proposedRoot, address caller) public {
        vm.assume(!distributionWithTimeLock.isUpdater(caller) && caller != owner);

        vm.prank(owner);
        distributionWithTimeLock.submitRoot(proposedRoot, DEFAULT_IPFS_HASH);

        vm.prank(caller);
        vm.expectRevert(bytes(ErrorsLib.NOT_UPDATER_ROLE));
        distributionWithTimeLock.revokePendingRoot();
    }

    function testRevokePendingRootShouldRevertWhenNoPendingRoot() public {
        vm.prank(owner);
        vm.expectRevert(bytes(ErrorsLib.NO_PENDING_ROOT));
        distributionWithTimeLock.revokePendingRoot();
    }

    function testSetOwner(address newOwner) public {
        vm.assume(newOwner != owner);

        vm.prank(owner);
        vm.expectEmit(address(distributionWithTimeLock));
        emit EventsLib.OwnerSet(newOwner);
        distributionWithTimeLock.setOwner(newOwner);

        assertEq(distributionWithTimeLock.owner(), newOwner);
    }

    function testSetOwnerShouldRevertIfNotOwner(address newOwner, address caller) public {
        vm.assume(caller != owner);

        vm.prank(caller);
        vm.expectRevert(bytes(ErrorsLib.NOT_OWNER));
        distributionWithTimeLock.setOwner(newOwner);
    }

    function testSetOwnerShouldRevertIfAlreadySet(address newOwner) public {
        vm.assume(newOwner != owner);

        vm.prank(owner);
        distributionWithTimeLock.setOwner(newOwner);

        vm.prank(newOwner);
        vm.expectRevert(bytes(ErrorsLib.ALREADY_SET));
        distributionWithTimeLock.setOwner(newOwner);
    }

    function testClaimShouldFollowTheMerkleDistribution(uint256 claimable, uint8 size) public {
        claimable = bound(claimable, 1 ether, 1000 ether);
        uint256 boundedSize = bound(size, 2, MAX_RECEIVERS);

        (bytes32[] memory data, bytes32 root) = _setupRewards(claimable, boundedSize);

        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(root, DEFAULT_IPFS_HASH);

        assertEq(distributionWithoutTimeLock.root(), root);

        _claimAndVerifyRewards(distributionWithoutTimeLock, data, claimable);
    }

    function testClaimShouldRevertIfClaimedTwice(uint256 claimable) public {
        claimable = bound(claimable, 1 ether, 1000 ether);

        (bytes32[] memory data, bytes32 root) = _setupRewards(claimable, 2);

        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(root, DEFAULT_IPFS_HASH);

        assertEq(distributionWithoutTimeLock.root(), root);
        bytes32[] memory proof1 = merkle.getProof(data, 0);

        vm.expectEmit(address(distributionWithoutTimeLock));
        emit EventsLib.Claimed(vm.addr(1), address(token1), claimable);
        distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable, proof1);

        vm.expectRevert(bytes(ErrorsLib.CLAIMABLE_TOO_LOW));
        distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable, proof1);
    }

    function testClaimShouldRevertIfRootMisconfigured(uint256 claimable) public {
        claimable = bound(claimable, 1 ether, 1000 ether);

        // We first define a correct root
        (bytes32[] memory data, bytes32 root) = _setupRewards(claimable, 2);

        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(root, DEFAULT_IPFS_HASH);
        bytes32[] memory proof1 = merkle.getProof(data, 0);
        distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable, proof1);

        // Now we define a misconfigured root with 2x less rewards
        (bytes32[] memory missconfiguredData, bytes32 missconfiguredRoot) = _setupRewards(claimable / 2, 2);

        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(missconfiguredRoot, DEFAULT_IPFS_HASH);
        bytes32[] memory missconfiguredProof1 = merkle.getProof(missconfiguredData, 0);

        vm.expectRevert(bytes(ErrorsLib.CLAIMABLE_TOO_LOW));
        distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable / 2, missconfiguredProof1);
    }

    function testClaimShouldReturnTheAmountClaimed(uint256 claimable) public {
        claimable = bound(claimable, 1 ether, 1000 ether);

        (bytes32[] memory data, bytes32 root) = _setupRewards(claimable, 2);

        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(root, DEFAULT_IPFS_HASH);

        assertEq(distributionWithoutTimeLock.root(), root);
        bytes32[] memory proof1 = merkle.getProof(data, 0);

        uint256 claimed = distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable, proof1);

        assertEq(claimed, claimable);

        // now, we will check if the amount claimed is reduced with the already claimed amount

        (bytes32[] memory data2, bytes32 root2) = _setupRewards(claimable * 2, 2);

        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(root2, DEFAULT_IPFS_HASH);

        assertEq(distributionWithoutTimeLock.root(), root2);
        bytes32[] memory proof2 = merkle.getProof(data2, 0);

        uint256 claimed2 = distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable * 2, proof2);

        assertEq(claimed2, claimable);
    }

    function testClaimShouldRevertIfNoRoot(uint256 claimable) public {
        claimable = bound(claimable, 1 ether, 1000 ether);

        (bytes32[] memory data,) = _setupRewards(claimable, 2);

        bytes32[] memory proof1 = merkle.getProof(data, 0);

        vm.expectRevert(bytes(ErrorsLib.ROOT_NOT_SET));
        distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable, proof1);
    }

    function testClaimShouldRevertIfInvalidRoot(uint256 claimable, bytes32 invalidRoot) public {
        vm.assume(invalidRoot != bytes32(0));

        claimable = bound(claimable, 1 ether, 1000 ether);

        (bytes32[] memory data, bytes32 root) = _setupRewards(claimable, 2);

        vm.assume(root != invalidRoot);
        vm.prank(owner);
        distributionWithoutTimeLock.setRoot(invalidRoot, DEFAULT_IPFS_HASH);

        bytes32[] memory proof1 = merkle.getProof(data, 0);

        vm.expectRevert(bytes(ErrorsLib.INVALID_PROOF_OR_EXPIRED));
        distributionWithoutTimeLock.claim(vm.addr(1), address(token1), claimable, proof1);
    }

    function _setupRewards(uint256 claimable, uint256 size)
        internal
        view
        returns (bytes32[] memory data, bytes32 root)
    {
        data = new bytes32[](size);

        uint256 i;
        while (i < size / 2) {
            uint256 index = i + 1;
            data[i] = keccak256(
                bytes.concat(keccak256(abi.encode(vm.addr(index), address(token1), uint256(claimable / index))))
            );
            data[i + 1] = keccak256(
                bytes.concat(keccak256(abi.encode(vm.addr(index), address(token2), uint256(claimable / index))))
            );

            i += 2;
        }

        root = merkle.getRoot(data);
    }

    struct Vars {
        uint256 i;
        uint256 index;
        uint256 claimableInput;
        uint256 claimableAdjusted1;
        uint256 claimableAdjusted2;
        uint256 balanceBefore1;
        uint256 balanceBefore2;
        uint256 UrdBalanceBefore1;
        uint256 UrdBalanceBefore2;
    }

    function _claimAndVerifyRewards(IUniversalRewardsDistributor distribution, bytes32[] memory data, uint256 claimable)
        internal
    {
        Vars memory vars;

        while (vars.i < data.length / 2) {
            bytes32[] memory proof1 = merkle.getProof(data, vars.i);
            bytes32[] memory proof2 = merkle.getProof(data, vars.i + 1);

            vars.index = vars.i + 1;
            vars.claimableInput = claimable / vars.index;
            vars.claimableAdjusted1 = vars.claimableInput - distribution.claimed(vm.addr(vars.index), address(token1));
            vars.claimableAdjusted2 = vars.claimableInput - distribution.claimed(vm.addr(vars.index), address(token2));
            vars.balanceBefore1 = token1.balanceOf(vm.addr(vars.index));
            vars.balanceBefore2 = token2.balanceOf(vm.addr(vars.index));
            vars.UrdBalanceBefore1 = token1.balanceOf(address(distribution));
            vars.UrdBalanceBefore2 = token2.balanceOf(address(distribution));

            // Claim token1
            vm.expectEmit(address(distribution));
            emit EventsLib.Claimed(vm.addr(vars.index), address(token1), vars.claimableAdjusted1);
            distribution.claim(vm.addr(vars.index), address(token1), vars.claimableInput, proof1);

            // Claim token2
            vm.expectEmit(address(distribution));
            emit EventsLib.Claimed(vm.addr(vars.index), address(token2), vars.claimableAdjusted2);
            distribution.claim(vm.addr(vars.index), address(token2), vars.claimableInput, proof2);

            uint256 balanceAfter1 = vars.balanceBefore1 + vars.claimableAdjusted1;
            uint256 balanceAfter2 = vars.balanceBefore2 + vars.claimableAdjusted2;

            assertEq(token1.balanceOf(vm.addr(vars.index)), balanceAfter1);
            assertEq(token2.balanceOf(vm.addr(vars.index)), balanceAfter2);
            // Assert claimed getter
            assertEq(distribution.claimed(vm.addr(vars.index), address(token1)), balanceAfter1);
            assertEq(distribution.claimed(vm.addr(vars.index), address(token2)), balanceAfter2);

            assertEq(token1.balanceOf(address(distribution)), vars.UrdBalanceBefore1 - vars.claimableAdjusted1);
            assertEq(token2.balanceOf(address(distribution)), vars.UrdBalanceBefore2 - vars.claimableAdjusted2);

            vars.i += 2;
        }
    }

    function _addrFromHashedString(string memory str) internal pure returns (address) {
        return address(uint160(uint256(keccak256(bytes(str)))));
    }
}
