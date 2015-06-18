using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string IsMatchesValue(string input, string pattern, int count)
    {
        Match match = Regex.Match(input, pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        int c = 1;
        if (match.Success && count == 1)
        {
            return match.Value;
        }
        while (match.Success)
        {
            if (c == count)
            {
                return match.Value;
            }
            match = match.NextMatch();
            c = c + 1;
        }
        return string.Empty;
    }
}