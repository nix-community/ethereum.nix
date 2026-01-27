{
  clang,
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  llvmPackages,
  openssl,
  sqlite,
  rust-jemalloc-sys,
  protobuf,
  rustPlatform,
  postgresql,
  foundry,
}:
let
  slasherContractVersion = "0.12.1";
  slasherContractSrc = fetchurl {
    url = "https://raw.githubusercontent.com/ethereum/eth2.0-specs/v${slasherContractVersion}/deposit_contract/contracts/validator_registration.json";
    sha256 = "sha256-ZslAe1wkmkg8Tua/AmmEfBmjqMVcGIiYHwi+WssEwa8=";
  };

  slasherContractTestVersion = "0.9.2.1";
  slasherContractTestnetSrc = fetchurl {
    url = "https://raw.githubusercontent.com/sigp/unsafe-eth2-deposit-contract/v${slasherContractTestVersion}/unsafe_validator_registration.json";
    sha256 = "sha256-aeTeHRT3QtxBRSNMCITIWmx89vGtox2OzSff8vZ+RYY=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "lighthouse";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "sigp";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-sdoyd1eBDX8AyiFdu6+23k//+vjxxfC6UNixZBeTLJw=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "quick-protobuf-0.8.1" = "sha256-dgePLYCeoEZz5DGaLifhf3gEIPaL7XB0QT9wRKY8LJg=";
      "libmdbx-0.1.4" = "sha256-ONp4uPkVCN84MObjXorCZuSjnM6uFSMXK1vdJiX074o=";
      "lmdb-rkv-0.14.0" = "sha256-sxmguwqqcyOlfXOZogVz1OLxfJPo+Q0+UjkROkbbOCk=";
      "xdelta3-0.1.5" = "sha256-aewSexOZCrQoKZQa+SGP8i6JKXstaxF3W2LVEhCSmPs=";
      "libp2p-gossipsub-0.50.0" = "sha256-RLPuPUUWlzv8tYyy7rr8wqR5OzP9TFtoz9QTdEHr+MM=";
    };
  };

  enableParallelBuilding = true;

  cargoBuildFlags = [ "--package lighthouse" ];

  nativeBuildInputs = [
    cmake
    clang
  ];
  buildInputs = [
    openssl
    protobuf
    sqlite
    rust-jemalloc-sys
  ];

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "gnosis"
    "portable"
    "slasher-lmdb"
  ];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  # Needed to get prost-build to use protobuf
  PROTOC = "${protobuf}/bin/protoc";

  # Needed by libmdx
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  # common crate tries to fetch the compiled version from an URL
  # see: https://github.com/sigp/lighthouse/blob/stable/common/deposit_contract/build.rs#L30
  LIGHTHOUSE_DEPOSIT_CONTRACT_SPEC_URL = "file:${slasherContractSrc}";

  # common crate tries to fetch the compiled version from an URL
  # see: https://github.com/sigp/lighthouse/blob/stable/common/deposit_contract/build.rs#L33
  LIGHTHOUSE_DEPOSIT_CONTRACT_TESTNET_URL = "file:${slasherContractTestnetSrc}";

  # This is needed by the unit tests.
  FORK_NAME = "capella";

  cargoTestFlags = [
    "--workspace"
    "--exclude beacon_chain"
    "--exclude beacon_node"
    "--exclude http_api"
    "--exclude lighthouse"
    "--exclude lighthouse_network"
    "--exclude network"
    "--exclude slashing_protection"
    "--exclude watch"
    "--exclude web3signer_tests"
    "--exclude lighthouse_metrics"
  ];

  nativeCheckInputs = [
    postgresql
    foundry
  ];

  checkFeatures = [ ];

  # All of these tests require network access
  checkFlags = [
    "--skip basic"
    "--skip deposit_tree::cache_consistency"
    "--skip deposit_tree::double_update"
    "--skip deposit_tree::updating"
    "--skip eth1_cache::big_skip"
    "--skip eth1_cache::double_update"
    "--skip eth1_cache::pruning"
    "--skip eth1_cache::simple_scenario"
    "--skip fast::deposit_cache_query"
    "--skip http::incrementing_deposits"
    "--skip persist::test_persist_caches"
    "--skip service::tests::tests::test_dht_persistence"
    "--skip time::test::test_reinsertion_updates_timeout"
    "--skip tests::broadcast_should_send_to_all_bns"
    "--skip tests::check_candidate_order"
    "--skip tests::first_success_should_try_nodes_in_order"
    "--skip tests::update_all_candidates_should_update_sync_status"
    "--skip engine_api::http::test::forkchoice_updated_v1_request"
    "--skip engine_api::http::test::forkchoice_updated_v1_with_payload_attributes_request"
    "--skip engine_api::http::test::get_block_by_hash_request"
    "--skip engine_api::http::test::get_block_by_number_request"
    "--skip engine_api::http::test::get_payload_v1_request"
    "--skip engine_api::http::test::geth_test_vectors"
    "--skip engine_api::http::test::new_payload_v1_request"
    "--skip test::finds_valid_terminal_block_hash"
    "--skip test::produce_three_valid_pos_execution_blocks"
    "--skip test::rejects_invalid_terminal_block_hash"
    "--skip test::rejects_terminal_block_with_equal_timestamp"
    "--skip test::rejects_unknown_terminal_block_hash"
    "--skip test::test_forked_terminal_block"
    "--skip test::verifies_valid_terminal_block_hash"
    "--skip invalid_attestation_unknown_target_root"
    "--skip invalid_attestation_unknown_beacon_block_root"
    "--skip invalid_block_unknown_parent"
    "--skip justified_balances"
    "--skip justified_and_finalized_blocks"
    "--skip invalid_block_future_slot"
    "--skip progressive_balances_cache_attester_slashing"
    "--skip justified_checkpoint_updates_with_descendent_first_justification"
    "--skip justified_checkpoint_updates_with_descendent"
    "--skip justified_checkpoint_updates_with_non_descendent"
    "--skip valid_attestation"
    "--skip valid_attestation_skip_across_epoch"
    "--skip weak_subjectivity_check_epoch_boundary_is_skip_slot"
    "--skip progressive_balances_cache_proposer_slashing"
    "--skip weak_subjectivity_check_fails_late_epoch"
    "--skip weak_subjectivity_check_fails_early_epoch"
    "--skip weak_subjectivity_check_fails_incorrect_root"
    "--skip weak_subjectivity_check_epoch_boundary_is_skip_slot_failure"
    "--skip weak_subjectivity_check_passes"
    "--skip weak_subjectivity_fail_on_startup"
    "--skip weak_subjectivity_pass_on_startup"
    "--skip can_read_finalized_block"
    "--skip invalid_block_finalized_descendant"
    "--skip invalid_block_finalized_slot"
    "--skip returns_200_ok"
    "--skip release_tests::attestation_aggregation_insert_get_prune"
    "--skip release_tests::attestation_duplicate"
    "--skip release_tests::attestation_get_max"
    "--skip release_tests::attestation_pairwise_overlapping"
    "--skip release_tests::attestation_rewards"
    "--skip release_tests::cross_fork_attester_slashings"
    "--skip release_tests::cross_fork_exits"
    "--skip release_tests::cross_fork_proposer_slashings"
    "--skip release_tests::duplicate_proposer_slashing"
    "--skip release_tests::max_coverage_attester_proposer_slashings"
    "--skip release_tests::max_coverage_different_indices_set"
    "--skip release_tests::max_coverage_effective_balances"
    "--skip release_tests::overlapping_max_cover_attester_slashing"
    "--skip release_tests::prune_attester_slashing_noop"
    "--skip release_tests::prune_proposer_slashing_noop"
    "--skip release_tests::simple_max_cover_attester_slashing"
    "--skip release_tests::sync_contribution_aggregation_insert_get_prune"
    "--skip release_tests::sync_contribution_duplicate"
    "--skip release_tests::sync_contribution_with_fewer_bits"
    "--skip release_tests::sync_contribution_with_more_bits"
    "--skip release_tests::test_earliest_attestation"
    "--skip per_block_processing::tests::invalid_bad_proposal_2_signature"
    "--skip per_block_processing::tests::invalid_block_header_state_slot"
    "--skip per_block_processing::tests::invalid_block_signature"
    "--skip per_block_processing::tests::invalid_deposit_bad_merkle_proof"
    "--skip per_block_processing::tests::invalid_deposit_count_too_small"
    "--skip per_block_processing::tests::invalid_deposit_deposit_count_too_big"
    "--skip per_block_processing::tests::invalid_deposit_invalid_pub_key"
    "--skip per_block_processing::tests::invalid_deposit_wrong_sig"
    "--skip per_block_processing::tests::invalid_parent_block_root"
    "--skip per_block_processing::tests::invalid_proposer_slashing_duplicate_slashing"
    "--skip per_block_processing::tests::invalid_proposer_slashing_proposal_epoch_mismatch"
    "--skip per_block_processing::tests::invalid_proposer_slashing_proposals_identical"
    "--skip per_block_processing::tests::invalid_proposer_slashing_proposer_unknown"
    "--skip per_block_processing::tests::invalid_randao_reveal_signature"
    "--skip per_block_processing::tests::valid_4_deposits"
    "--skip per_block_processing::tests::valid_block_ok"
    "--skip per_block_processing::tests::valid_insert_attester_slashing"
    "--skip per_block_processing::tests::valid_insert_proposer_slashing"
    "--skip per_epoch_processing::tests::release_tests::altair_state_on_base_fork"
    "--skip per_epoch_processing::tests::release_tests::base_state_on_altair_fork"
    "--skip per_epoch_processing::tests::runs_without_error"
    "--skip per_block_processing::tests::block_replayer_peeking_state_roots"
    "--skip per_block_processing::tests::fork_spanning_exit"
    "--skip per_block_processing::tests::invalid_attester_slashing_1_invalid"
    "--skip per_block_processing::tests::invalid_attester_slashing_2_invalid"
    "--skip per_block_processing::tests::invalid_attester_slashing_not_slashable"
    "--skip per_block_processing::tests::invalid_bad_proposal_1_signature"
    "--skip exit::custom_tests::valid"
    "--skip exit::custom_tests::valid_three"
    "--skip exit::tests::invalid_bad_signature"
    "--skip exit::tests::invalid_duplicate"
    "--skip exit::tests::invalid_exit_already_initiated"
    "--skip exit::tests::invalid_future_exit_epoch"
    "--skip exit::tests::invalid_not_active_after_exit_epoch"
    "--skip exit::tests::invalid_not_active_before_activation_epoch"
    "--skip exit::tests::invalid_too_young_by_a_lot"
    "--skip exit::tests::invalid_too_young_by_one_epoch"
    "--skip exit::tests::invalid_validator_unknown"
    "--skip exit::tests::valid_genesis_epoch"
    "--skip exit::tests::valid_previous_epoch"
    "--skip exit::tests::valid_single_exit"
    "--skip exit::tests::valid_three_exits"
    "--skip iter::test::block_root_iter"
    "--skip iter::test::state_root_iter"
    "--skip beacon_state::committee_cache::tests::initializes_with_the_right_epoch"
    "--skip beacon_state::committee_cache::tests::min_randao_epoch_correct"
    "--skip beacon_state::committee_cache::tests::shuffles_for_the_right_epoch"
    "--skip beacon_state::tests::beacon_proposer_index"
    "--skip beacon_state::tests::cache_initialization"
    "--skip beacon_state::tests::committees::current_epoch_committee_consistency"
    "--skip beacon_state::tests::committees::next_epoch_committee_consistency"
    "--skip beacon_state::tests::committees::previous_epoch_committee_consistency"
    "--skip tests::keystores::import_wrong_number_of_passwords"
    "--skip tests::keystores::migrate_all_with_slashing_protection"
    "--skip tests::keystores::migrate_some_extra_slashing_protection"
    "--skip tests::keystores::migrate_some_missing_slashing_protection"
    "--skip tests::keystores::migrate_some_with_slashing_protection"
    "--skip tests::prefer_builder_proposals_validator"
    "--skip tests::routes_with_invalid_auth"
    "--skip tests::simple_getters"
    "--skip tests::validator_builder_boost_factor"
    "--skip tests::validator_builder_boost_factor_global_builder_proposals_false"
    "--skip tests::validator_builder_boost_factor_global_builder_proposals_true"
    "--skip tests::validator_builder_boost_factor_global_prefer_builder_proposals_true"
    "--skip tests::validator_builder_boost_factor_global_prefer_builder_proposals_true_override"
    "--skip tests::validator_builder_proposals"
    "--skip tests::validator_derived_builder_boost_factor_with_process_defaults"
    "--skip tests::validator_enabling"
    "--skip tests::validator_exit"
    "--skip tests::validator_gas_limit"
    "--skip tests::validator_graffiti"
    "--skip tests::validator_graffiti_api"
    "--skip tests::web3signer_validator_creation"
    "--skip tests::keystores::delete_then_reimport_remotekeys"
    "--skip tests::keystores::get_auth_no_token"
    "--skip tests::keystores::get_empty_keystores"
    "--skip tests::keystores::get_empty_remotekeys"
    "--skip tests::keystores::get_web3_signer_keystores"
    "--skip tests::keystores::import_and_delete_conflicting_web3_signer_keystores"
    "--skip tests::keystores::import_invalid_slashing_protection"
    "--skip tests::keystores::import_keystores_wrong_password"
    "--skip tests::keystores::import_new_keystores"
    "--skip tests::keystores::import_new_remotekeys"
    "--skip tests::keystores::import_only_duplicate_keystores"
    "--skip tests::keystores::import_only_duplicate_remotekeys"
    "--skip tests::keystores::import_remote_and_local_keys"
    "--skip tests::keystores::import_remotekey_web3signer"
    "--skip tests::keystores::import_remotekey_web3signer_disabled"
    "--skip tests::keystores::import_remotekey_web3signer_enabled"
    "--skip tests::keystores::import_same_local_and_remote_keys"
    "--skip tests::keystores::import_same_remote_and_local_keys"
    "--skip tests::keystores::import_same_remotekey_different_url"
    "--skip tests::keystores::import_some_duplicate_keystores"
    "--skip tests::keystores::import_some_duplicate_remotekeys"
    "--skip tests::hd_validator_creation"
    "--skip tests::invalid_pubkey"
    "--skip tests::keystore_validator_creation"
    "--skip tests::keystores::check_get_set_fee_recipient"
    "--skip tests::keystores::check_get_set_gas_limit"
    "--skip tests::keystores::delete_concurrent_with_signing"
    "--skip tests::keystores::delete_keystores_twice"
    "--skip tests::keystores::delete_nonexistent_keystores"
    "--skip tests::keystores::delete_nonexistent_remotekey"
    "--skip tests::keystores::delete_remotekey_then_reimport_different_url"
    "--skip tests::keystores::delete_remotekeys_twice"
    "--skip tests::keystores::delete_then_reimport"
    "--skip import_validators::tests::import_duplicates_when_disallowed"
    "--skip import_validators::tests::import_duplicates_when_disallowed_keystore_format"
    "--skip list_validators::test::list_all_validators"
    "--skip move_validators::test::no_validators"
    "--skip move_validators::test::one_validator_move_all"
    "--skip move_validators::test::one_validator_move_all_with_password_files"
    "--skip move_validators::test::one_validator_move_one"
    "--skip move_validators::test::one_validator_to_non_empty_dest"
    "--skip move_validators::test::one_validators_move_two_by_count"
    "--skip move_validators::test::three_validators_move_all"
    "--skip move_validators::test::three_validators_move_one"
    "--skip move_validators::test::three_validators_move_one_by_count"
    "--skip move_validators::test::three_validators_move_three"
    "--skip move_validators::test::three_validators_move_two"
    "--skip move_validators::test::three_validators_move_two_by_count"
    "--skip move_validators::test::two_validator_move_all_and_back_again"
    "--skip move_validators::test::two_validator_move_all_passwords_removed"
    "--skip move_validators::test::two_validator_move_all_passwords_removed_failed_password_attempt"
    "--skip move_validators::test::two_validators_move_all_where_one_is_a_duplicate"
    "--skip move_validators::test::two_validators_move_one_where_one_is_a_duplicate"
    "--skip move_validators::test::two_validators_move_one_with_identical_password_files"
    "--skip create_validators::tests::bogus_bn_url"
    "--skip delete_validators::test::delete_multiple_validators"
    "--skip import_validators::tests::create_one_validator"
    "--skip import_validators::tests::create_one_validator_keystore_format"
    "--skip import_validators::tests::create_one_validator_with_offset"
    "--skip import_validators::tests::create_one_validator_with_offset_keystore_format"
    "--skip import_validators::tests::create_three_validators"
    "--skip import_validators::tests::create_three_validators_with_offset"
    "--skip import_validators::tests::import_duplicates_when_allowed"
    "--skip import_validators::tests::import_duplicates_when_allowed_keystore_format"
  ];

  passthru.category = "Consensus Clients";

  meta = {
    description = "Ethereum consensus client in Rust";
    homepage = "https://github.com/sigp/lighthouse";
    license = lib.licenses.asl20;
    mainProgram = "lighthouse";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
