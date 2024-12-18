import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"

import "dotenv/config"

const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL ?? ""
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL ?? ""
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY ?? ""

const config: HardhatUserConfig = {
	defaultNetwork: "hardhat",
	networks: {
		hardhat: {
			forking: {
				url: MAINNET_RPC_URL,
			},
		},
		sepolia: {
			url: SEPOLIA_RPC_URL,
			accounts: [SEPOLIA_PRIVATE_KEY],
		},
	},
	etherscan: {
		apiKey: {
			sepolia: "5BSHVNUZ4N21U46JEBW1PAR6T3YVDTYRHN",
		},
	},
	solidity: {
		version: "0.8.27",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
			viaIR: true, // Enable via-IR compilation
		},
	},
}

export default config
