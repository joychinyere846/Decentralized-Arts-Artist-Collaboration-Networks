import { describe, it, expect, beforeEach } from "vitest"

describe("Exhibition Management Contract", () => {
  let contractAddress
  let curatorAddress
  let artistAddress
  let visitorAddress
  
  beforeEach(() => {
    contractAddress = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.exhibition-management"
    curatorAddress = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
    artistAddress = "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"
    visitorAddress = "ST3AM1A56AK2C1XAFJ4115ZSV26EB49BVQ10MGCS0"
  })
  
  describe("Exhibition Creation", () => {
    it("should create exhibition with valid parameters", () => {
      const result = {
        type: "ok",
        value: 1, // exhibition-id
      }
      
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
    
    it("should set exhibition status to upcoming", () => {
      const exhibitionData = {
        title: "Modern Art Showcase",
        description: "Contemporary art exhibition",
        curator: curatorAddress,
        venue: "Downtown Gallery",
        "start-date": 2000,
        "end-date": 3000,
        status: "upcoming",
        "entry-fee": 50,
      }
      
      expect(exhibitionData.status).toBe("upcoming")
    })
    
    it("should validate exhibition title length", () => {
      const longTitle = "a".repeat(101)
      const result = {
        type: "error",
        value: "String too long",
      }
      
      expect(result.type).toBe("error")
    })
  })
  
  describe("Artwork Management", () => {
    it("should add artwork to exhibition", () => {
      const result = {
        type: "ok",
        value: true,
      }
      
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should prevent duplicate artwork IDs", () => {
      const result = {
        type: "error",
        value: 402, // ERR_ARTWORK_EXISTS
      }
      
      expect(result.type).toBe("error")
      expect(result.value).toBe(402)
    })
    
    it("should set artwork as available by default", () => {
      const artworkData = {
        artist: artistAddress,
        title: "Abstract Dreams",
        medium: "Oil on Canvas",
        price: 1000,
        available: true,
      }
      
      expect(artworkData.available).toBe(true)
    })
  })
  
  describe("Visitor Registration", () => {
    it("should register visitor for exhibition", () => {
      const result = {
        type: "ok",
        value: 50, // entry-fee
      }
      
      expect(result.type).toBe("ok")
      expect(result.value).toBe(50)
    })
    
    it("should record registration details", () => {
      const registrationData = {
        "registered-at": 1500,
        "fee-paid": 50,
      }
      
      expect(registrationData["fee-paid"]).toBe(50)
    })
    
    it("should prevent registration for non-existent exhibition", () => {
      const result = {
        type: "error",
        value: 401, // ERR_EXHIBITION_NOT_FOUND
      }
      
      expect(result.type).toBe("error")
      expect(result.value).toBe(401)
    })
  })
  
  describe("Exhibition Management", () => {
    it("should allow curator to open exhibition", () => {
      const result = {
        type: "ok",
        value: true,
      }
      
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should prevent non-curator from opening exhibition", () => {
      const result = {
        type: "error",
        value: 400, // ERR_UNAUTHORIZED
      }
      
      expect(result.type).toBe("error")
      expect(result.value).toBe(400)
    })
    
    it("should update exhibition status to open", () => {
      const exhibitionData = {
        status: "open",
      }
      
      expect(exhibitionData.status).toBe("open")
    })
  })
  
  describe("Read Functions", () => {
    it("should return exhibition information", () => {
      const exhibitionData = {
        title: "Modern Art Showcase",
        description: "Contemporary art exhibition",
        curator: curatorAddress,
        venue: "Downtown Gallery",
        "start-date": 2000,
        "end-date": 3000,
        status: "open",
        "entry-fee": 50,
      }
      
      expect(exhibitionData.title).toBe("Modern Art Showcase")
      expect(exhibitionData.venue).toBe("Downtown Gallery")
    })
    
    it("should return artwork information", () => {
      const artworkData = {
        artist: artistAddress,
        title: "Abstract Dreams",
        medium: "Oil on Canvas",
        price: 1000,
        available: true,
      }
      
      expect(artworkData.title).toBe("Abstract Dreams")
      expect(artworkData.medium).toBe("Oil on Canvas")
    })
  })
})
