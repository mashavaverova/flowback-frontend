// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import {PollHelpers} from "./PollHelpers.sol";
import {ProposalHelpers} from "./ProposalHelpers.sol";
import {PredictionHelpers} from "./PredictionHelpers.sol";
import {PredictionBetHelpers} from "./PredictionBetHelpers.sol";

/**
 * @title PredictionBets
 * @dev This contract manages prediction bets placed by users on proposals within polls. It extends PollHelpers, ProposalHelpers, PredictionHelpers, and PredictionBetHelpers.
 * @notice This contract allows users to place and retrieve prediction bets, ensuring that the poll, proposal, and prediction exist before placing bets.
 * @author @EllenLng, @KristofferGW
 * @notice Audited by @MashaVaverova
 */
contract PredictionBets is PollHelpers, ProposalHelpers, PredictionHelpers, PredictionBetHelpers {
    /**
     * @notice Emitted when a new prediction bet is created.
     * @param predictionId The ID of the prediction for which the bet is placed.
     * @param bet Boolean indicating if the bet is for or against the prediction.
     * @param likelihood The likelihood score assigned to the prediction by the user.
     */
    event PredictionBetCreated(uint256 indexed predictionId, bool bet, uint256 likelihood);

    /**
     * @notice Modifier to check that a poll, proposal, and prediction exist before placing or retrieving a bet.
     * @param _pollId The ID of the poll to check.
     * @param _proposalId The ID of the proposal to check.
     * @param _predictionId The ID of the prediction to check.
     */
    modifier requireExist(uint256 _pollId, uint256 _proposalId, uint256 _predictionId) {
        requirePollToExist(_pollId);
        requireProposalToExist(_pollId, _proposalId);
        requirePredictionToExist(_proposalId, _predictionId);
        _;
    }

    /**
     * @notice Places a new prediction bet for a specific poll, proposal, and prediction.
     * @dev The function ensures that the poll, proposal, and prediction exist, and the likelihood is greater than 0 before placing the bet.
     * @param _pollId The ID of the poll associated with the bet.
     * @param _proposalId The ID of the proposal associated with the bet.
     * @param _predictionId The ID of the prediction being bet on.
     * @param _likelihood The likelihood score given by the user for the prediction.
     * @param _bet Boolean indicating whether the user is betting for or against the prediction.
     */
    function placePredictionBet(
        uint256 _pollId,
        uint256 _proposalId,
        uint256 _predictionId,
        uint256 _likelihood,
        bool _bet
    ) external requireExist(_pollId, _proposalId, _predictionId) {
        require(_likelihood > 0, "Likelihood must be greater than 0");

        PredictionBet[] storage bets = predictionBets[_predictionId];
        bets.push(
            PredictionBet({
                pollId: _pollId,
                proposalId: _proposalId,
                predictionId: _predictionId,
                likelihood: _likelihood,
                bet: _bet
            })
        );
        emit PredictionBetCreated(_predictionId, _bet, _likelihood);
    }

    /**
     * @notice Retrieves all bets made for a specific prediction within a poll and proposal.
     * @param _pollId The ID of the poll associated with the bets.
     * @param _proposalId The ID of the proposal associated with the bets.
     * @param _predictionId The ID of the prediction for which to retrieve bets.
     * @return An array of PredictionBet structs representing all bets made on the prediction.
     */
    function getPredictionBets(uint256 _pollId, uint256 _proposalId, uint256 _predictionId)
        external
        view
        requireExist(_pollId, _proposalId, _predictionId)
        returns (PredictionBet[] memory)
    {
        return predictionBets[_predictionId];
    }
}
