using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections;
using System.Collections.Generic;
using ConnectedItemSets;
//using System.Threading;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void GetConnectedPublnSets()
    {

        using (var connection = new SqlConnection("context connection=true"))
        {
            connection.Open();
            using (SqlCommand command = connection.CreateCommand())
            {

                SqlDataRecord record = new SqlDataRecord(new SqlMetaData[] {
                new SqlMetaData("cluster", SqlDbType.Int),
                new SqlMetaData("npl_publn_id", SqlDbType.Int)
                    });

                SqlContext.Pipe.SendResultsStart(record);


                List<int> publnUT = new List<int>();
                List<int> pubMinPairIndex = new List<int>();
                List<int> pubMaxPairIndex = new List<int>();
                List<int> pairPub2Index = new List<int>();

                command.CommandText = string.Format("select npl_publn_id, min_pair_index, max_pair_index from tmp_publns4 order by pub_index");

                using (SqlDataReader reader = command.ExecuteReader())
                    while (reader.Read())
                    {
                        publnUT.Add(reader.GetInt32(0));
                        pubMinPairIndex.Add(reader.GetInt32(1));
                        pubMaxPairIndex.Add(reader.GetInt32(2));
                    }
                command.CommandText = string.Format("select publn2_index from tmp_publn_pairs3 order by pair_index");

                using (SqlDataReader reader = command.ExecuteReader())
                    while (reader.Read())
                        pairPub2Index.Add(reader.GetInt32(0));

                ConnectedPubSetSearcher connectedPubSetSearcher = new ConnectedPubSetSearcher(pubMinPairIndex, pubMaxPairIndex, pairPub2Index);
                List<List<int>> connectedPubSets = connectedPubSetSearcher.getConnectedPubSets();

                for (int i = 0; i < connectedPubSets.Count; i++)
                {
                    record.SetValue(0, i);
                    for (int j = 0; j < connectedPubSets[i].Count; j++)
                    {
                        record.SetValue(1, publnUT[connectedPubSets[i][j]]);
                        SqlContext.Pipe.SendResultsRow(record);
                    }
                }
                SqlContext.Pipe.SendResultsEnd();
            }
        }
    }
};