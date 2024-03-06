/*
 * Copyright (c) [2024] SUSE LLC
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
import { screen, within } from "@testing-library/react";
import { plainRender } from "~/test-utils";
import { ProposalTransactionalInfo } from "~/components/storage";

jest.mock("~/context/product", () => ({
  ...jest.requireActual("~/context/product"),
  useProduct: () => ({
    selectedProduct : { name: "Test" }
  })
}));

let props;

beforeEach(() => {
  props = {};
});

const rootVolume = { mountPath: "/", fsType: "Btrfs" };

describe("if the system is not transactional", () => {
  beforeEach(() => {
    props.settings = { volumes: [rootVolume] };
  });

  it("does not render any explanation about transactional system", () => {
    plainRender(<ProposalTransactionalInfo {...props} />);

    expect(screen.queryByText("Transactional root file system")).toBeNull();
  });
});

describe("if the system is transactional", () => {
  beforeEach(() => {
    props.settings = { volumes: [{ ...rootVolume, transactional: true }] };
  });

  it("renders an explanation about the transactional system", () => {
    plainRender(<ProposalTransactionalInfo {...props} />);

    screen.getByText("Transactional root file system");
  });
});
