/*
 * Copyright (c) [2023] SUSE LLC
 *
 * All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, contact SUSE LLC.
 *
 * To contact SUSE LLC about this file by physical or electronic mail, you may
 * find current contact information at www.suse.com.
 */

import React from "react";
import { Link } from "react-router-dom";

import { Icon, Title, PageIcon, MainActions } from "~/components/layout";

/**
 * Displays an installation page
 * @component
 *
 * @example <caption>Simple usage</caption>
 *   <Page
 *     title="Users settings"
 *     icon="manage_accounts"
 *   >
 *     <UserSectionContent />
 *   </Page>
 *
 * @example <caption>Using custom action label and callback</caption>
 *   <Page
 *     title="Users settings"
 *     icon="manage_accounts"
 *     actionLabel="Do it!"
 *     actionCallback={() => console.log("Doing it...")}
 *   >
 *     <UserSectionContent />
 *   </Page>
 *
 * @example <caption>Using a component for the primary action</caption>
 *   <Page
 *     title="Users settings"
 *     icon="manage_accounts"
 *     action={<Button onClick={() => console.log("Doing it...")}>Do it!</Button>}
 *   >
 *     <UserSectionContent />
 *   </Page>
 *
 * @param {object} props
 * @param {string} props.icon - The icon for the page
 * @param {string} props.title - The title for the page
 * @param {string} [props.navigateTo="/"] - The path where the page will go after when user clicks on accept
 * @param {JSX.Element} [props.action] - an element used as primary action. If present, actionLabel and actionCallback does not make effect
 * @param {string} [props.actionLabel="Accept"] - The label for the primary page action
 * @param {string} [props.actionVariant="primary"] - The PF/Button variant for the page action
 * @param {function} [props.actionCallback=noop] - A callback to be execute when triggering the primary action
 * @param {JSX.Element} [props.children] - the section content
 */
export default function Page({
  icon,
  title,
  action,
  actionLabel,
  children
}) {
  return (
    <>
      { title && <Title>{title}</Title> }
      { icon && <PageIcon><Icon name={icon} /></PageIcon> }
      <MainActions>
        { action ||
          <Link to=".." state={{ goingBack: true }} unstable_viewTransition>
            {actionLabel}
          </Link> }
      </MainActions>
      {children}
    </>
  );
}
