import { ContentLayout, AppLayout, Header } from '@cloudscape-design/components'
import React, { createRef } from 'react'
import { applyMode, Mode } from '@cloudscape-design/global-styles';

// enable dark mode
applyMode(Mode.Dark);

class FleetwiseAppLayout extends React.Component {
  constructor(props) {
    super(props);

    this.state = { toolsIndex: 0, toolsOpen: false };
    this.appLayout = createRef();
  }

  loadHelpPanelContent(index) {
    this.setState({ toolsIndex: index, toolsOpen: true });
    this.appLayout.current?.focusToolsClose();
  }

  render() {
    return (
      <AppLayout
        ref={this.appLayout}
        content={
          <ContentLayout
            header={<Header
              variant="h3"
            >
              IoT Fleetwise Demo
            </Header>}
          >
              {this.props.children}
          </ContentLayout>
        }
        headerSelector=".app-nav"
        //breadcrumbs={<Box></Box>}
        //navigation={<Box>abcd</Box>}
        // tools={ToolsContent[this.state.toolsIndex]}
        //toolsOpen={this.state.toolsOpen}
        onToolsChange={({ detail }) => this.setState({ toolsOpen: detail.open })}
        contentType="form"
        ariaLabels={{}}
      // notifications={<Notifications />}
      />
    );
  }
}

export default FleetwiseAppLayout;