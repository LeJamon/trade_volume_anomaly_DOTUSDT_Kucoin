import initSqlJs from "sql.js";
import fs from "fs";
import moment from 'moment';


export default function Main(props) {
  const data = {
    columns: props.request[0].columns,
    values: props.request[0].values,
  };
  
  return (
    <div className="container">
      <h1 className="title">Traded Volume Anomaly on DOT/USDT on Kucoin</h1>
      <table>
        <thead>
          <tr>
            {data.columns.map((column) => (
              <th key={column}>{column}</th>
            ))}
          </tr>
        </thead>
        <tbody>
        {data.values.map(value => (
          <tr key={value} data-value={value[1]}>
            <td >{value[0]}</td>
            <td >{value[1]}</td>
            <td >{moment.unix(value[2] / 1000000000).format('YYYY-MM-DD HH:mm:ss')}</td>
            
          </tr>
              )
          )}
        </tbody>
      </table>     
    </div>
  );
}

export async function getStaticProps() {
  const SQL = await initSqlJs();
  const filebuffer = fs.readFileSync("database/trade.db");
  const db = new SQL.Database(filebuffer);
  const request = db.exec("Select * from Anomalie order by time desc");
  return { props: { request } };
}
