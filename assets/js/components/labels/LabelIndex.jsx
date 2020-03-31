import React, { Component } from 'react'
import DashboardLayout from '../common/DashboardLayout'
import CreateLabelModal from './CreateLabelModal'
import DeleteLabelModal from './DeleteLabelModal'
import RemoveAllDevicesFromLabelsModal from './RemoveAllDevicesFromLabelsModal'
import LabelIndexTable from './LabelIndexTable'
import analyticsLogger from '../../util/analyticsLogger'
import { Button } from 'antd';

class LabelIndex extends Component {
  state = {
    showCreateLabelModal: false,
    showDeleteLabelModal: false,
    showRemoveAllDevicesFromLabelsModal: false,
    labelsSelected: null,
  }

  componentDidMount() {
    analyticsLogger.logEvent("ACTION_NAV_LABELS_INDEX")
  }

  openCreateLabelModal = () => {
    this.setState({ showCreateLabelModal: true })
  }

  closeCreateLabelModal = () => {
    this.setState({ showCreateLabelModal: false })
  }

  openDeleteLabelModal = (labelsSelected) => {
    this.setState({ showDeleteLabelModal: true, labelsSelected })
  }

  closeDeleteLabelModal = () => {
    this.setState({ showDeleteLabelModal: false })
  }

  openRemoveAllDevicesFromLabelsModal = (labelsSelected) => {
    this.setState({ showRemoveAllDevicesFromLabelsModal: true, labelsSelected })
  }

  closeRemoveAllDevicesFromLabelsModal = () => {
    this.setState({ showRemoveAllDevicesFromLabelsModal: false })
  }

  render() {
    const { showRemoveAllDevicesFromLabelsModal, showCreateLabelModal, showDeleteLabelModal, labelsSelected } = this.state
    return (
      <DashboardLayout title="Labels">
        <LabelIndexTable
          openCreateLabelModal={this.openCreateLabelModal}
          openDeleteLabelModal={this.openDeleteLabelModal}
          openRemoveAllDevicesFromLabelsModal={this.openRemoveAllDevicesFromLabelsModal}
        />

        <CreateLabelModal
          open={showCreateLabelModal}
          onClose={this.closeCreateLabelModal}
        />

        <DeleteLabelModal
          open={showDeleteLabelModal}
          onClose={this.closeDeleteLabelModal}
          labelsToDelete={labelsSelected}
        />

        <RemoveAllDevicesFromLabelsModal
          open={showRemoveAllDevicesFromLabelsModal}
          onClose={this.closeRemoveAllDevicesFromLabelsModal}
          labels={labelsSelected}
        />
      </DashboardLayout>
    )
  }
}

export default LabelIndex
