const walletAddress = await window.ethereum.request({
    method: 'eth_requestAccounts',
    params: [
      {
        eth_accounts: {}
      }
    ]
  });

  const carol = sf.user({
    address: walletAddress[0],
    token: '0x...',
});  