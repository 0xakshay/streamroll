// Instant distribution agreement
import SuperfluidSDK from '@superfluid-finance/js-sdk';
import { Web3Provider } from '@ethersproject/providers';
import { BigNumber } from '@ethersproject/bignumber';

const testPool = async () => {
    const walletAddress = await window.ethereum.request({
      method: 'eth_requestAccounts',
      params: [
        {
          eth_accounts: {}
        }
      ]
    });
    const sf = new SuperfluidSDK.Framework({
      ethers: new Web3Provider(window.ethereum),
      tokens: ['fDAI']
    });
    await sf.initialize();
    const carol = sf.user({
      address: walletAddress[0],
      token: '0x...'
    });
    await carol.createPool({ poolId: 1 });
    await carol.giveShares({
      poolId: 1,
      shares: 100,
      recipient: '0x...'
    });
    await carol.distributeToPool({
      poolId: 1,
      amount: BigNumber.from(100).toString()
    });
  };
  
testPool();