'use strict'

const fs = require('fs')
const path = require('path')
// const _ = require('lodash')
const execSync = require('child_process').execSync

function sequence (promises) {
  return promises.length === 0 ? Promise.resolve()
    : promises[0].then(() => sequence(promises.slice(1)))
}

function executeStatements (knex, sql) {
  const statements = sql.split(';\n')
  return sequence(statements.map((statement) => {
    const line = statement.replace('\n', '')
    return line ? knex.raw(line) : Promise.resolve()
  }))
}

function executeOracleSql (sqlFile, knexConfig) {
  const username = knexConfig.connection.user
  const password = knexConfig.connection.password
  const host = knexConfig.connection.host
  const port = knexConfig.connection.port
  const database = knexConfig.connection.database
  const executionString =
    `${username}/${password}@${host}${port ? ':' + port : ''}/${database} @ ${sqlFile}`

  const executionResult =
    execSync(`DYLD_LIBRARY_PATH=/opt/oracle/instantclient sqlplus ${executionString}`).toString('utf8')

  const hasErrors = executionResult.indexOf('ERROR') !== -1

  if (hasErrors) {
    console.error('Error executing Oracle SQL', executionResult)
    return Promise.reject(new Error('Error executing Oracle SQL'))
  }

  return Promise.resolve()
}

function createTables (knex, knexConfig) {
  const dbType = knex.client.config.client
  const filepath = path.resolve(
    __dirname, '..', 'sql', dbType, 'create.sql')

  if (dbType === 'strong-oracle') {
    return executeOracleSql(filepath, knexConfig)
  }

  const sql = fs.readFileSync(filepath, {encoding: 'utf8'})
  return executeStatements(knex, sql)
}

module.exports = {
  createTables
}
