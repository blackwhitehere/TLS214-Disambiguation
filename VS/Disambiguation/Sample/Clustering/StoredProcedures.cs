using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections;
using System.Collections.Generic;
using ConnectedItemSets;
using System.Threading;

//public partial class StoredProcedures
//{
//    [Microsoft.SqlServer.Server.SqlProcedure]
//    public static void GetConnectedPubSets3()
//    {
//        SqlContext.Pipe.Send("Test");

//        var emiel = new Emiel();

//        ThreadStart job = new ThreadStart(emiel.testMethod);
//        Thread thread = new Thread(job, 100000000);
//        thread.Start();

//        //while (thread.ThreadState == ThreadState.Running)
//        //{

//        //}

//        SqlContext.Pipe.Send(thread.ThreadState.ToString());

//    }

//    public class Emiel
//    {

//        public void testMethod()
//        {
//            SqlContext.Pipe.Send("ggggggsss");

//            List<int> blocks_to_process = new List<int>();

//            using (var connection = new SqlConnection("context connection=true"))
//            {
//                connection.Open();
//                using (SqlCommand command = connection.CreateCommand())
//                {
//                    command.CommandText = "select block_id from block_processing order by block_id";
//                    using (SqlDataReader reader = command.ExecuteReader())
//                        while (reader.Read())
//                            blocks_to_process.Add(reader.GetInt32(0));

//                    SqlDataRecord record = new SqlDataRecord(new SqlMetaData[] {
//                new SqlMetaData("block_id", SqlDbType.Int),
//                new SqlMetaData("cluster", SqlDbType.Int),
//                new SqlMetaData("ut", SqlDbType.Char, 15)
//                    });

//                    SqlContext.Pipe.SendResultsStart(record);

//                    for (int k = 0; k < blocks_to_process.Count; k++)
//                    {
//                        List<string> pubUT = new List<string>();
//                        List<int> pubMinPairIndex = new List<int>();
//                        List<int> pubMaxPairIndex = new List<int>();
//                        List<int> pairPub2Index = new List<int>();

//                        command.CommandText = string.Format("select ut, min_pair_index, max_pair_index from tmp_blocks_pubs4 where block_id = {0} order by pub_index", blocks_to_process[k]);

//                        using (SqlDataReader reader = command.ExecuteReader())
//                            while (reader.Read())
//                            {
//                                pubUT.Add(reader.GetString(0));
//                                pubMinPairIndex.Add(reader.GetInt32(1));
//                                pubMaxPairIndex.Add(reader.GetInt32(2));
//                            }
//                        command.CommandText = string.Format("select pub2_index from tmp_blocks_pub_pairs3 where block_id = {0} order by pair_index", blocks_to_process[k]);

//                        using (SqlDataReader reader = command.ExecuteReader())
//                            while (reader.Read())
//                                pairPub2Index.Add(reader.GetInt32(0));

//                        ConnectedPubSetSearcher connectedPubSetSearcher = new ConnectedPubSetSearcher(pubMinPairIndex, pubMaxPairIndex, pairPub2Index);
//                        List<List<int>> connectedPubSets = connectedPubSetSearcher.getConnectedPubSets();

//                        for (int i = 0; i < connectedPubSets.Count; i++)
//                        {
//                            record.SetValue(0, blocks_to_process[k]);
//                            record.SetValue(1, i);
//                            for (int j = 0; j < connectedPubSets[i].Count; j++)
//                            {
//                                record.SetValue(2, pubUT[connectedPubSets[i][j]]);
//                                SqlContext.Pipe.SendResultsRow(record);
//                            }
//                        }
//                    }
//                    SqlContext.Pipe.SendResultsEnd();
//                }
//            }
//        }

//    }

//};


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void GetConnectedPubSets4()
    {
        List<int> blocks_to_process = new List<int>();

        using (var connection = new SqlConnection("context connection=true"))
        {
            connection.Open();
            using (SqlCommand command = connection.CreateCommand())
            {
                command.CommandText = "select block_id from block_processing order by block_id";
                using (SqlDataReader reader = command.ExecuteReader())
                    while (reader.Read())
                        //blocks_to_process.Add(Convert.ToInt32(reader.GetInt32(0)));
                        blocks_to_process.Add(reader.GetInt32(0));

                SqlDataRecord record = new SqlDataRecord(new SqlMetaData[] {
                new SqlMetaData("block_id", SqlDbType.Int),
                new SqlMetaData("cluster", SqlDbType.Int),
                new SqlMetaData("ut", SqlDbType.Char, 15),
                new SqlMetaData("au_count", SqlDbType.Int)
                    });

                SqlContext.Pipe.SendResultsStart(record);

                for (int k = 0; k < blocks_to_process.Count; k++)
                {
                    List<string> pubUT = new List<string>();
                    List<int> pubAuCount = new List<int>();
                    List<int> pubMinPairIndex = new List<int>();
                    //var pubMinPairIndex = new List<Int64>();
                    List<int> pubMaxPairIndex = new List<int>();
                    List<int> pairPub2Index = new List<int>();

                    //command.CommandText = string.Format("select ut, min_pair_index, max_pair_index from tmp_blocks_pubs4 where block_id = {0} order by pub_index", blocks_to_process[k]);
                    command.CommandText = string.Format("select ut, au_count, min_pair_index, max_pair_index from tmp_blocks_pubs4 where block_id = {0} order by pub_index", blocks_to_process[k]);

                    //command.CommandText = "select ut, min_pair_index, max_pair_index from tmp_blocks_pubs4 where block_id = " + blocks_to_process[k] + " order by pub_index";
                    using (SqlDataReader reader = command.ExecuteReader())
                        while (reader.Read())
                        {
                            pubUT.Add(reader.GetString(0));
                            //pubMinPairIndex.Add(Convert.ToInt32(reader.GetInt64(1)));
                            pubAuCount.Add(reader.GetInt32(1));
                            pubMinPairIndex.Add(reader.GetInt32(2));
                            //pubMaxPairIndex.Add(Convert.ToInt32(reader.GetInt64(2)));
                            pubMaxPairIndex.Add(reader.GetInt32(3));
                        }
                    //command.CommandText = "select pub2_index from tmp_blocks_pub_pairs3 where block_id = " + blocks_to_process[k] + " order by pair_index";
                    command.CommandText = string.Format("select pub2_index from tmp_blocks_pub_pairs3 where block_id = {0} order by pair_index", blocks_to_process[k]);

                    using (SqlDataReader reader = command.ExecuteReader())
                        while (reader.Read())
                            //                            pairPub2Index.Add(Convert.ToInt32(reader.GetInt64(0)));
                            pairPub2Index.Add(reader.GetInt32(0));

                    ConnectedPubSetSearcher connectedPubSetSearcher = new ConnectedPubSetSearcher(pubMinPairIndex, pubMaxPairIndex, pairPub2Index);
                    List<List<int>> connectedPubSets = connectedPubSetSearcher.getConnectedPubSets();

                    //SqlDataRecord record = new SqlDataRecord(new SqlMetaData[] {
                    //new SqlMetaData("block_id", SqlDbType.Int),
                    //new SqlMetaData("cluster", SqlDbType.Int),
                    //new SqlMetaData("ut", SqlDbType.Char, 15)
                    //    });
                    //SqlContext.Pipe.SendResultsStart(record);

                    //foreach (var connectedPubSet in connectedPubSets)
                    //{
                    //    record.SetValue(1, connectedPubSet);
                    //}


                    for (int i = 0; i < connectedPubSets.Count; i++)
                    {
                        record.SetValue(0, blocks_to_process[k]);
                        record.SetValue(1, i);
                        for (int j = 0; j < connectedPubSets[i].Count; j++)
                        {
                            record.SetValue(2, pubUT[connectedPubSets[i][j]]);
                            record.SetValue(3, pubAuCount[connectedPubSets[i][j]]);
                            SqlContext.Pipe.SendResultsRow(record);
                        }
                    }
                    //SqlContext.Pipe.SendResultsEnd();
                }
                SqlContext.Pipe.SendResultsEnd();
            }
        }
    }
};



//public partial class StoredProcedures
//{
//    [Microsoft.SqlServer.Server.SqlProcedure]
//    public static void GetConnectedPubSets2(SqlInt32 block_id)
//    {
//        List<string> pubUT = new List<string>();
//        List<int> pubMinPairIndex = new List<int>();
//        List<int> pubMaxPairIndex = new List<int>();
//        List<int> pairPub2Index = new List<int>();

//        using (var connection = new SqlConnection("context connection=true"))
//        {
//            connection.Open();
//            using (SqlCommand command = connection.CreateCommand())
//            {
//                command.CommandText = "select ut, min_pair_index, max_pair_index from tmp_blocks_pubs4 where block_id = " + block_id + " order by pub_index";
//                using (SqlDataReader reader = command.ExecuteReader())
//                    while (reader.Read())
//                    {
//                        pubUT.Add(reader.GetString(0));
//                        pubMinPairIndex.Add(Convert.ToInt32(reader.GetInt64(1)));
//                        pubMaxPairIndex.Add(Convert.ToInt32(reader.GetInt64(2)));
//                    }
//                command.CommandText = "select pub2_index from tmp_blocks_pub_pairs3 where block_id = " + block_id + " order by pair_index";
//                using (SqlDataReader reader = command.ExecuteReader())
//                    while (reader.Read())
//                        pairPub2Index.Add(Convert.ToInt32(reader.GetInt64(0)));
//            }
//        }

//        ConnectedPubSetSearcher connectedPubSetSearcher = new ConnectedPubSetSearcher(pubMinPairIndex, pubMaxPairIndex, pairPub2Index);
//        List<List<int>> connectedPubSets = connectedPubSetSearcher.getConnectedPubSets();

//        SqlDataRecord record = new SqlDataRecord(new SqlMetaData[] {
//                new SqlMetaData("block_id", SqlDbType.Int),
//                new SqlMetaData("cluster", SqlDbType.Int),
//                new SqlMetaData("ut", SqlDbType.Char, 15)
//            });
//        SqlContext.Pipe.SendResultsStart(record);
//        for (int i = 0; i < connectedPubSets.Count; i++)
//        {
//            record.SetValue(0, block_id);
//            record.SetValue(1, i);
//            for (int j = 0; j < connectedPubSets[i].Count; j++)
//            {
//                record.SetValue(2, pubUT[connectedPubSets[i][j]]);
//                SqlContext.Pipe.SendResultsRow(record);
//            }
//        }
//        SqlContext.Pipe.SendResultsEnd();
//    }
//};
