// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "./base/DSTest.sol";
import { console } from "./utils/console.sol";
import { BaseTest, MockErc20Like, NFTBoostedLeverageControllerLike, MockPancakeswapV2WorkerLike, DebtTokenLike, SimpleVaultConfigLike, VaultLike, MockNFTLike, NFTStakingLike } from "./base/BaseTest.sol";

contract NFTBoostedLeverageControllerTest is BaseTest {
  NFTBoostedLeverageControllerLike private nftBoostedController;

  // MockERC20
  MockErc20Like private cakeToken;
  MockErc20Like private WBNB;

  NFTStakingLike private nftStaking;

  // Mock NFT
  MockNFTLike private mockNFT1;
  MockNFTLike private mockNFT2;
  MockNFTLike private mockNFT3;

  // Mock Worker
  MockPancakeswapV2WorkerLike private mockWorker1;
  MockPancakeswapV2WorkerLike private mockWorker2;
  MockPancakeswapV2WorkerLike private mockWorker3;

  // PoolID
  address private poolId1;
  address private poolId2;
  address private poolId3;

  // mockWorker address
  address private mockWorker1Address;
  address private mockWorker2Address;
  address private mockWorker3Address;

  uint256[] private workFactors;
  uint256[] private killFactors;
  address[] private poolIds;
  address[] private mockWorkers;

  function setUp() external {
    nftStaking = _setupNFTStaking();
    cakeToken = _setupToken("CakeToken", "CAKE", 18);
    WBNB = _setupToken("Wrapped BNB", "WBNB", 18);
    mockNFT1 = _setupMockNFT();
    mockNFT2 = _setupMockNFT();
    mockNFT3 = _setupMockNFT();
    poolId1 = address(mockNFT1);
    poolId2 = address(mockNFT2);
    poolId3 = address(mockNFT3);

    nftBoostedController = _setupNFTBoostedLeverageController(address(nftStaking));

    mockWorker1 = _setupPancakeswapV2Worker();
    mockWorker2 = _setupPancakeswapV2Worker();
    mockWorker3 = _setupPancakeswapV2Worker();

    mockWorker1Address = address(mockWorker1);
    mockWorker2Address = address(mockWorker2);
    mockWorker3Address = address(mockWorker3);
  }

  function testSetBoostedLeverage_goodParams() external {
    workFactors = [34, 56, 76];
    killFactors = [50, 60, 80];
    poolIds = [poolId1, poolId2, poolId3];
    mockWorkers = [mockWorker1Address, mockWorker2Address, mockWorker3Address];
    nftStaking.addPool(poolId1, 100, 0, 200);
    nftStaking.addPool(poolId2, 100, 0, 200);
    nftStaking.addPool(poolId3, 100, 0, 200);
    nftBoostedController.setBoosted(poolIds, mockWorkers, workFactors, killFactors);
  }

  function testSetBoostedLeverage_badParams() external {
    workFactors = [34, 56, 76];
    killFactors = [50, 60, 80];
    poolIds = [poolId1, poolId2, poolId3];
    mockWorkers = [mockWorker1Address, mockWorker2Address];
    nftStaking.addPool(poolId1, 100, 0, 200);
    nftStaking.addPool(poolId2, 100, 0, 200);
    nftStaking.addPool(poolId3, 100, 0, 200);
    vm.expectRevert(NFTBoostedLeverageControllerLike.NFTBoostedLeverageController_BadParamsLength.selector);
    nftBoostedController.setBoosted(poolIds, mockWorkers, workFactors, killFactors);
  }

  function testGetBoostedWorkFactor_success() external {
    workFactors = [34, 56, 76];
    killFactors = [50, 60, 80];
    poolIds = [poolId1, poolId2, poolId3];
    mockWorkers = [mockWorker1Address, mockWorker2Address, mockWorker3Address];

    nftStaking.addPool(poolId1, 100, 0, 200);
    nftStaking.addPool(poolId2, 100, 0, 200);
    nftStaking.addPool(poolId3, 100, 0, 200);

    vm.startPrank(ALICE, ALICE);
    mockNFT1.mint(1);
    mockNFT1.approve(address(nftStaking), 0);
    assertEq(mockNFT1.balanceOf(ALICE), 1);
    nftStaking.stakeNFT(poolId1, 0, 20);
    vm.stopPrank();
    nftBoostedController.setBoosted(poolIds, mockWorkers, workFactors, killFactors);
    assertEq(nftBoostedController.getBoostedWorkFactor(ALICE, mockWorker1Address, 0), 34);
  }

  function testGetBoostedWorkFactor_noNFTStake() external {
    workFactors = [34, 56, 76];
    killFactors = [50, 60, 80];
    poolIds = [poolId1, poolId2, poolId3];
    mockWorkers = [mockWorker1Address, mockWorker2Address, mockWorker3Address];

    nftStaking.addPool(poolId1, 100, 0, 200);
    nftStaking.addPool(poolId2, 100, 0, 200);
    nftStaking.addPool(poolId3, 100, 0, 200);

    vm.startPrank(ALICE, ALICE);
    mockNFT1.mint(1);
    mockNFT1.approve(address(nftStaking), 0);
    assertEq(mockNFT1.balanceOf(ALICE), 1);
    vm.stopPrank();
    nftBoostedController.setBoosted(poolIds, mockWorkers, workFactors, killFactors);
    assertEq(nftBoostedController.getBoostedWorkFactor(ALICE, mockWorker1Address, 0), 0);
  }

  function testGetBoostedKillFactor_success() external {
    workFactors = [34, 56, 76];
    killFactors = [50, 60, 80];
    poolIds = [poolId1, poolId2, poolId3];
    mockWorkers = [mockWorker1Address, mockWorker2Address, mockWorker3Address];

    nftStaking.addPool(poolId1, 100, 0, 200);
    nftStaking.addPool(poolId2, 100, 0, 200);
    nftStaking.addPool(poolId3, 100, 0, 200);

    vm.startPrank(ALICE, ALICE);
    mockNFT1.mint(1);
    mockNFT1.approve(address(nftStaking), 0);
    assertEq(mockNFT1.balanceOf(ALICE), 1);
    nftStaking.stakeNFT(poolId1, 0, 20);
    vm.stopPrank();
    nftBoostedController.setBoosted(poolIds, mockWorkers, workFactors, killFactors);
    assertEq(nftBoostedController.getBoostedKillFactor(ALICE, mockWorker1Address, 0), 50);
  }

    function testGetBoostedKillFactor_noNFTSstake() external {
    workFactors = [34, 56, 76];
    killFactors = [50, 60, 80];
    poolIds = [poolId1, poolId2, poolId3];
    mockWorkers = [mockWorker1Address, mockWorker2Address, mockWorker3Address];

    nftStaking.addPool(poolId1, 100, 0, 200);
    nftStaking.addPool(poolId2, 100, 0, 200);
    nftStaking.addPool(poolId3, 100, 0, 200);

    vm.startPrank(ALICE, ALICE);
    mockNFT1.mint(1);
    mockNFT1.approve(address(nftStaking), 0);
    assertEq(mockNFT1.balanceOf(ALICE), 1);
    vm.stopPrank();
    nftBoostedController.setBoosted(poolIds, mockWorkers, workFactors, killFactors);
    assertEq(nftBoostedController.getBoostedKillFactor(ALICE, mockWorker1Address, 0), 0);
  }

}
