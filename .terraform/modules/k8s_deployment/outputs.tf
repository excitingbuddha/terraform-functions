output "resolved_config_map_name" {
  value = kubernetes_config_map.sportsbook_mts_bet_recon_config.metadata[0].name
}
