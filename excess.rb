<% @number.times do |i|%>
  <tr>
    <td><%= TotalScore.find(i+1).ticker%></td>
    <td><%= TotalScore.find(i+1).average_score%></td>
  </tr>
<%end%>
