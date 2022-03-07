import axios from 'axios';

const endpoint = 'https://hub.snapshot.org/graphql';

type Vote = {
  id: number
  voter: string
}

type APIResponse = {
  data: {
    votes: Vote[]
  }
};

const main = async () => {
//   const voter = "0xFe3DdB7883c3f09e1fdc9908B570C6C79fB25f7C";
  const voter = "0x58Eb67DcA41dAC355cE0E9858bA3e8E9e867FC93"
  const query = `
    query Votes {
      votes (
        first: 1
        skip: 0
        where: {
          voter: "${voter}"
        }
      ) {
        id
        voter
      }
    }
  `;
  const res = await axios.post<APIResponse>(endpoint, { query });
  console.log(res.data.data)
  console.log(res.data.data.votes.length >= 1);
};

main();