import React, { Component } from 'react'
import analyticsLogger from '../../util/analyticsLogger'
import { Typography, Input, Row, Col } from 'antd';
const { Text } = Typography

const styles = {
  container: {
    backgroundColor: '#E6F7FF',
    padding: 24,
    borderRadius: 8,
  },
  inputHeader: {
    color: '#096DD9',
  },
  input: {
    marginTop: 8
  },
}

const AmountEntryCalculator = ({ countDC, countB, countUSD, handleCountInputUpdate, disabled }) => (
  <div>
    <Text strong>Enter a quantity you wish to purchase</Text>
    <div style={{ ...styles.container, marginTop: 12 }}>
      <Row gutter={12} style={{ marginBottom: 12 }}>
        <Col span={12}>
          <Text style={styles.inputHeader}>Amount of Data Credits</Text>
          <Input
            placeholder="Enter Quantity"
            name="countDC"
            value={countDC}
            onChange={handleCountInputUpdate}
            style={styles.input}
            type="number"
            disabled={disabled}
          />
          {
            countB > 0 && <Text>= {countB} Bytes of Data</Text>
          }
        </Col>
        <Col span={12}>
          <Text style={styles.inputHeader}>Amount in USD$</Text>
          <Input
            placeholder="Enter Quantity"
            name="countUSD"
            value={countUSD}
            onChange={handleCountInputUpdate}
            style={styles.input}
            type="number"
            disabled={disabled}
          />
        </Col>
      </Row>
    </div>
  </div>
)

export default AmountEntryCalculator
