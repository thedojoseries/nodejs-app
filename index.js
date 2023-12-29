const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  priv_ip = process.env.PRIV_IP
  res.send(`Instance IP: ${priv_ip}`)
})

app.listen(port, () => {
  console.log(`app listening on port ${port}`)
})
