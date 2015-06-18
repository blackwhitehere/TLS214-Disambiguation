using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string RegexGetPart(string input, string pattern, int part)
    {
        string[] result = Regex.Split(input, pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        string result_output = "";

        if ((result != null || result.Length > 0) & (part < result.Length))
        {
            return result_output = result[part];
        }
        return string.Empty;
    }
}