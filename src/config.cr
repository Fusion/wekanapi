require "./toml.cr"

CONFIG = TOML.parse File.read "config.toml"
