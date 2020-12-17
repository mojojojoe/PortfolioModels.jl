using Dates

this_year = year(today(Dates.today())
this_month = month(Dates.today())
this_day = day(Dates.today())

           
function read_ohlc(stock::String, fm::Int, fd::Int, fy::Int, tm::Int, td::Int, ty::Int, period::String)

# take care of yahoo's 0 indexing for month
    fm -= 1
    tm -= 1

    ydata     = readlines(`curl -s "http://ichart.finance.yahoo.com/table.csv?s=$stock&a=$fm&b=$fd&c=$fy&d=$tm&e=$td&f=$ty&g=$period"`)
    numstring = ydata[2:end]
    sa  = split(numstring[1], ',')'

    for i in 2:length(numstring) 
        sa  = [sa ; split(numstring[i], ',')']
    end

    time_conversion = map(x -> parse("yyyy-MM-dd", x), convert(Array{UTF16String}, sa[:,1]))

    ohlc = DataFrame(quote
        Date  = $time_conversion
        Open  = float($sa[:,2])
        High  = float($sa[:,3])
        Low   = float($sa[:,4])
        Close = float($sa[:,5])
        Vol   =   int($sa[:,6])
        Adj   = float($sa[:,7])
    end)

    flipud(ohlc)

end


                 
# monthly data 

window = 3 # years

monthly_ohlc_over_window(stock::String) = read_ohlc(stock::String, this_month, this_day, this_year - window, this_month,  this_day, this_year, "m")


                 
# TODO make the portfolio list unlimited in length                
function returns{T <: Union(ASCIIString, UTF8String)}(list::Array{T})

    str1 = list[1]
    str2 = list[2]
    str3 = list[3]
    str4 = list[4]
    str5 = list[5]

    s1 = monthly_ohlc_over_window(list[1]) 
    s2 = monthly_ohlc_over_window(list[2]) 
    s3 = monthly_ohlc_over_window(list[3]) 
    s4 = monthly_ohlc_over_window(list[4]) 
    s5 = monthly_ohlc_over_window(list[5]) 

    r1 = log_return(s1["Adj"])
    r2 = log_return(s2["Adj"])
    r3 = log_return(s3["Adj"])
    r4 = log_return(s4["Adj"])
    r5 = log_return(s5["Adj"])

    ohlc = DataFrame(quote
        $str1 = $r1 
        $str2 = $r2 
        $str3 = $r3 
        $str4 = $r4 
        $str5 = $r5 
    end)
    ohlc[2:end, :]
end

# function read_monthlies(filename::String)

#     ohlc  = read_table(filename)
#     time_conversion =  Calendar.parse("MMM-yy", ohlc[:,1]) 

#     within!(ohlc, quote
#         Date = $(time_conversion)
#     end)

# # flipud(df)
# end





