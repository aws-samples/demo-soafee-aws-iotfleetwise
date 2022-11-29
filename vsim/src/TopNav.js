import * as React from "react";
import TopNavigation from "@cloudscape-design/components/top-navigation";

const TopNav = () => {
  return (
    <div className="app-nav">
      <TopNavigation
        identity={{
          href: "#",
          title: ""
        }}
        utilities={[
          {
            text: "Demo user",
          }
        ]}
        i18nStrings={{
          searchIconAriaLabel: "Search",
          searchDismissIconAriaLabel: "Close search",
          overflowMenuTriggerText: "More",
          overflowMenuTitleText: "All",
          overflowMenuBackIconAriaLabel: "Back",
          overflowMenuDismissIconAriaLabel: "Close menu"
        }}
      />
    </div>
  );
}

export default TopNav;