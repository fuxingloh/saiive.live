enum ChainType { Bitcoin, DeFiChain }

enum ChainNet { Mainnet, Testnet }

class ChainHelper {
  static String chainTypeString(ChainType type) {
    switch (type) {
      case ChainType.Bitcoin:
        return "BTC";
      case ChainType.DeFiChain:
        return "DFI";
    }

    return null;
  }

  static String chainNetworkString(ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        return "mainnet";
      case ChainNet.Testnet:
        return "testnet";
    }
    return null;
  }
}
