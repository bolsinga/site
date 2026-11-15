//
//  VenuePlacesFilterTests.swift
//
//
//  Created by Greg Bolsinga on 11/14/26.
//

import Testing

@testable import SiteApp

struct VenuePlacesFilterTests {
  private func facts(
    status: VenuePickStatus = .picked, isModified: Bool = false, hasStreet: Bool = true, sharesLocation: Bool = false,
    hasWebsite: Bool = true, hasPlace: Bool = true, addressDiffers: Bool = false,
    identifierChanged: Bool = false, placeGone: Bool = false
  ) -> VenueFacts {
    VenueFacts(
      status: status, isModified: isModified, hasStreet: hasStreet, sharesLocation: sharesLocation,
      hasWebsite: hasWebsite, hasPlace: hasPlace, addressDiffers: addressDiffers,
      identifierChanged: identifierChanged, placeGone: placeGone)
  }

  @Test func modifiedIsChangedThisSession() {
    #expect(VenuePlacesFilter.modified.includes(facts(isModified: true)))
    #expect(!VenuePlacesFilter.modified.includes(facts(status: .picked)))
  }

  @Test func suggestedIsSuggested() {
    #expect(VenuePlacesFilter.suggested.includes(facts(status: .suggested)))
    #expect(!VenuePlacesFilter.suggested.includes(facts(status: .unpicked)))
  }

  @Test func criteriaMatchTheirFacts() {
    #expect(VenuePlacesFilter.noStreet.includes(facts(hasStreet: false)))
    #expect(!VenuePlacesFilter.noStreet.includes(facts()))
    #expect(VenuePlacesFilter.sharesLocation.includes(facts(sharesLocation: true)))
    #expect(VenuePlacesFilter.noWebsite.includes(facts(hasWebsite: false)))
    #expect(VenuePlacesFilter.noMapKitID.includes(facts(hasPlace: false)))
    #expect(VenuePlacesFilter.addressDiffers.includes(facts(addressDiffers: true)))
    #expect(VenuePlacesFilter.identifierChanged.includes(facts(identifierChanged: true)))
    #expect(VenuePlacesFilter.placeGone.includes(facts(placeGone: true)))
    #expect(!VenuePlacesFilter.placeGone.includes(facts(identifierChanged: true)))
    #expect(!VenuePlacesFilter.identifierChanged.includes(facts(placeGone: true)))
    for filter in VenuePlacesFilter.criteria {
      #expect(!filter.includes(facts()))
    }
  }
}
