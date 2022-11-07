import * as React from "react";
import TopNavigation from "@cloudscape-design/components/top-navigation";

const TopNav = () => {
  return (
    <div className="app-nav">
      <TopNavigation
        identity={{
          href: "#",
          title: "",
          logo: {
            src: "aws_logo.png",
            alt: "Service"
          }
        }}
        utilities={[
          {
            // type: "menu-dropdown",
            // type: "button",
            text: "Demo user",
            // description: "demouser@amazon.com",
            // iconName: "user-profile",
            // items: [
            //   { id: "signout", text: "Sign out" }
            // ]
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