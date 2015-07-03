using System;
using System.Collections.Generic;
//using System.Linq;

namespace ConnectedItemSets
{

    class ConnectedPubSetSearcher
    {
        private List<int> pubMinPairIndex;
        private List<int> pubMaxPairIndex;
        private List<int> pairPub2Index;
        private int nPubs;

        public ConnectedPubSetSearcher(List<int> pubMinPairIndex, List<int> pubMaxPairIndex, List<int> pairPub2Index)
        {
            this.pubMinPairIndex = pubMinPairIndex;
            this.pubMaxPairIndex = pubMaxPairIndex;
            this.pairPub2Index = pairPub2Index;
            nPubs = pubMinPairIndex.Count;
        }

        public List<List<int>> getConnectedPubSets()
        {
            List<List<int>> connectedPubSets = new List<List<int>>();
            bool[] assigned = new bool[nPubs];
            for (int i = 0; i < nPubs; i++)
                if (!assigned[i])
                {
                    List<int> connectedPubSet = new List<int>();
                    searchForConnectedPubs(i, connectedPubSet, assigned);
                    connectedPubSets.Add(connectedPubSet);
                }
            return connectedPubSets;
        }

        public void searchForConnectedPubs(int i, List<int> connectedPubSet, bool[] assigned)
        {
            connectedPubSet.Add(i);
            assigned[i] = true;
            for (int j = 0; j < nPubs; j++)
                if (!assigned[j] && connectedPubs(j, pubMinPairIndex[i], pubMaxPairIndex[i]))
                    searchForConnectedPubs(j, connectedPubSet, assigned);
        }

        private bool connectedPubs(int j, int minPairIndex, int maxPairIndex)
        {
            if (maxPairIndex < minPairIndex)
                return false;
            int mid = minPairIndex + ((maxPairIndex - minPairIndex) / 2);
            if (pairPub2Index[mid] > j)
                return connectedPubs(j, minPairIndex, mid - 1);
            else if (pairPub2Index[mid] < j)
                return connectedPubs(j, minPairIndex + 1, maxPairIndex);
            return true;
        }
    }
}
