// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

interface INFTBoostedLeverageController {
  function getBoostedWorkFactor(address _owner, address _worker, uint256 _nftTokenId) external view returns (uint256);

  function getBoostedKillFactor(address _owner, address _worker, uint256 _nftTokenId) external view returns (uint256);
}
