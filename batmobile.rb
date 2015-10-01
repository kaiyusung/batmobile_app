#required modules
require 'csv'
require 'matrix'

#loading tickers
symbols = CSV.read('symbols.csv')
symbols2 = CSV.read('symbols2.csv')
symbols3 = CSV.read('symbols3.csv')
symbols4 = CSV.read('symbols4.csv')
#declaring variables
revenue = 0
diluted = 0
operating_income = 0
income_after_tax = 0
debt = 0
holder = "yes" #holder to check if long-term debt is null, if it is move to other liabilites.
equity = 0
operating_cash = 0
free_cash = 0

operating_profit_margin = []
max_operating_profit_margin = [0.0,0.0,0.0,0.0,0.0]
score_operating_profit_margin = []
debt_equity = []
roic = []
max_roic = [0.0,0.0,0.0,0.0,0.0]
score_roic = []
cash_flow = []
max_cash_flow = [0.0,0.0,0.0,0.0,0.0]
score_cash_flow = []
capital_ratio = []
max_capital_ratio = [0.0,0.0,0.0,0.0,0.0]
score_capital_ratio = []


row2 = [] #for max operating_profit
row3 = [] #for score_operating_profit_margin
row4 = [] #for max roic
row5 = [] #for score_roic
row6 = [] #for max cash_flow
row7 = [] #for score_cash_flow
row8 = [] #for max capital_ratio
row9 = [] #for score_capital_ratio
row10 = []#for total score

#first part of logic, extracting the data.
#operating profit margin
symbols.each do |row|
  #opening up csv files.
  #balance_sheet = CSV.read("data/#{row[0]}_BalanceSheet.csv", headers: :first_row)
  income_statment = CSV.read("data/#{row[0]}_IncomeStatement.csv",headers: :first_row)
  #cash_flow = CSV.read("data/#{row[0]}_CashFlow.csv", headers: :first_row)

  #extracting information from the income_statment
  income_statment.each do |row|
    if (row[0] == 'Revenue' or row[0] == 'Revenues, net of interest expense' or row[0] == 'Total net revenue' or row[0] == 'Total revenues')
      revenue = row
    end
    #choosing the second diluted
    if (row[0] == 'Diluted')
      if !(row[1]['.'])
        diluted = row
      end
    end
    if (row[0] == 'Income before income taxes'  or row[0] == 'Operating income' or row[0] == 'Income (loss) from cont ops before taxes' )
      operating_income = row
    end
    if (row[0] == 'Net income available to common shareholders')
      income_after_tax = row
    end
  end
     #puts revenue[1]
     #puts operating_income[1]
     #puts diluted[1]
     #puts income_after_tax[1]
     for i in 1..5
       if (operating_income[i].to_f < 0 and revenue[i].to_f < 0)
         operating_profit_margin[i] = - (operating_income[i].to_f / revenue[i].to_f)
       else
         operating_profit_margin[i] = operating_income[i].to_f / revenue[i].to_f
       end
       row << operating_profit_margin[i]
     end
     row2 << row
     #puts operating_profit_margin[1]
     #puts max_operating_profit_margin[-1]
     row3
end

#puts row2
#finding out the max
for i in 1..5
  max_operating_profit_margin[i] = row2.map {|row| row[i]}.max
  #max_roic[i] = row4.map {|row| row[i]}.max
end

row2.each do |row|
    for i in 1..5
      row[i] = row[i] / max_operating_profit_margin[i]*25
    end
    if (row[i] < -25)
      row[i] = -25
    end
    row3 << row
end

CSV.open('operating_profit_margin.csv','w') do |csv_object|
  row3.each do |row_array|
    csv_object << row_array
  end
end

#puts row3

#logic for roic part
symbols2.each do |row|
  holder = "yes"
  #puts row[0]
  #opening up csv files.
  balance_sheet = CSV.read("data/#{row[0]}_BalanceSheet.csv", headers: :first_row)
  income_statment = CSV.read("data/#{row[0]}_IncomeStatement.csv",headers: :first_row)
  #cash_flow = CSV.read("data/#{row[0]}_CashFlow.csv", headers: :first_row)

  #extracting information from the income_statment
  income_statment.each do |row|
    if (row[0] == 'Revenue' or row[0] == 'Revenues, net of interest expense' or row[0] == 'Total net revenue' or row[0] == 'Total revenues')
      revenue = row
    end
    #choosing the second diluted
    if (row[0] == 'Diluted')
      if !(row[1]['.'])
        diluted = row
      end
    end
    if (row[0] == 'Income before income taxes'  or row[0] == 'Operating income' or row[0] == 'Income (loss) from cont ops before taxes' )
      operating_income = row
    end
    if (row[0] == 'Net income available to common shareholders')
      income_after_tax = row
    end
  end

   #extracting information from balance sheet.
  balance_sheet.each do |row|
   if (row[0] == 'Long-term debt')
     debt = row
     holder = "no"
   elsif (row[0] == 'Other long-term liabilities' && holder.to_s != "no")
     #puts holder
     debt = row
   end
   for i in 1..5
    if (debt[i].to_s == "")
      debt[i] = 0
    end
   end

  if (row[0] == "Total Stockholders' equity" or row[0] == "Total stockholders' equity")
    equity = row
  end
 end
 #puts debt

  for i in 1..5
    if equity[i].to_f < 0
      debt_equity[i] = debt[i].to_f - equity[i].to_f
    else
      debt_equity[i] = debt[i].to_f + equity[i].to_f
    end
    if (debt_equity[i].to_f < 0 and income_after_tax[i].to_f < 0)
      roic[i] = - (income_after_tax[i].to_f / debt_equity[i].to_f)
    else
      roic[i] = income_after_tax[i].to_f / debt_equity[i].to_f
    end
    row << roic[i]
  end

#  puts row

  row4 << row
  row5
end
#finding out the max
for i in 1..5
  max_roic[i] = row4.map {|row| row[i]}.max
end

row4.each do |row|
    for i in 1..5
      row[i] = row[i] / max_roic[i]*25
    end
    if (row[i] < -25)
      row[i] = -25
    end
    row5 << row
end

CSV.open('roic.csv','w') do |csv_object|
  row5.each do |row_array|
    csv_object << row_array
  end
end

#puts row5

#logic for cash_flow part
symbols3.each do |row|
  #opening up csv files.
  #balance_sheet = CSV.read("data/#{row[0]}_BalanceSheet.csv", headers: :first_row)
  #income_statment = CSV.read("data/#{row[0]}_IncomeStatement.csv",headers: :first_row)
  cash_flow = CSV.read("data/#{row[0]}_CashFlow.csv", headers: :first_row)

   #extracting information from cash flow sheet.
  cash_flow.each do |row|
   if (row[0] == 'Net cash provided by operating activities')
     operating_cash = row
   end
   if (row[0] == 'Free cash flow' or row[0] == 'Net income')
     free_cash = row
   end
  end

  #puts free_cash
  #puts operating_cash

  for i in 1..5
    if (operating_cash[i].to_f < 0 and free_cash[i].to_f < 0)
      cash_flow[i] = - (free_cash[i].to_f / operating_cash[i].to_f)
    else
      cash_flow[i] = free_cash[i].to_f / operating_cash[i].to_f
    end
    row << cash_flow[i]
  end

#  puts row

  row6 << row
  row7
end
#finding out the max
for i in 1..5
  max_cash_flow[i] = row6.map {|row| row[i]}.max
end

row6.each do |row|
    for i in 1..5
      row[i] = row[i] / max_cash_flow[i]*25
      if (row[i] < -25)
        row[i] = -25
      end
    end
    row7 << row
end

CSV.open('cash_flow.csv','w') do |csv_object|
  row7.each do |row_array|
    csv_object << row_array
  end
end

#puts row7

#logic for capital_ratio part
symbols4.each do |row|
  holder = "yes"
  #puts row[0]
  #opening up csv files.
  balance_sheet = CSV.read("data/#{row[0]}_BalanceSheet.csv", headers: :first_row)
  #income_statment = CSV.read("data/#{row[0]}_IncomeStatement.csv",headers: :first_row)
  #cash_flow = CSV.read("data/#{row[0]}_CashFlow.csv", headers: :first_row)

   #extracting information from balance sheet.
   balance_sheet.each do |row|
    if (row[0] == 'Long-term debt')
      debt = row
      holder = "no"
    elsif (row[0] == 'Other long-term liabilities' && holder.to_s != "no")
      #puts holder
      debt = row
    end
    for i in 1..5
     if (debt[i].to_s == "")
       debt[i] = 0
     end
    end

  if (row[0] == "Total Stockholders' equity" or row[0] == "Total stockholders' equity")
    equity = row
  end
 end
 #puts debt

  for i in 1..5
    if equity[i].to_f < 0
      debt_equity[i] = debt[i].to_f - equity[i].to_f
    else
      debt_equity[i] = debt[i].to_f + equity[i].to_f
    end
    if (debt_equity[i].to_f < 0 and equity[i].to_f < 0)
      capital_ratio[i] = - (equity[i].to_f / debt_equity[i].to_f)
    else
      capital_ratio[i] = equity[i].to_f / debt_equity[i].to_f
    end
    row << capital_ratio[i]
  end

  row8 << row
  row9
end
#finding out the max
for i in 1..5
  max_capital_ratio[i] = row8.map {|row| row[i]}.max
end

row8.each do |row|
    for i in 1..5
      row[i] = row[i] / max_capital_ratio[i]*25
      if (row[i] < -25)
        row[i] = -25
      end
    end
    row9 << row
end

CSV.open('captial_ratio.csv','w') do |csv_object|
  row9.each do |row_array|
    csv_object << row_array
  end
end
