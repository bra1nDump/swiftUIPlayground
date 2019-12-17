//
//  ContentView.swift
//  SwiftUIPlayground
//
//  Created by Konstantin Dubovitskiy on 12/12/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import SwiftUI

struct Item: Identifiable {
    let name: String
    let price: Float
    let id: String
    
    init(name: String, price: Float) {
        self.name = name
        self.price = price
        id = name
    }
}

protocol Store {
    associatedtype Inventory: RandomAccessCollection where Inventory.Element == Item
    var inventory: Inventory { get }
}

class UnoMarket: Store {
    let inventory = [
        Item(name: "Cabbage", price: 1),
        Item(name: "Rediska", price: 2),
        Item(name: "Pikles", price: 0.5)
    ]
}

class Cart: ObservableObject {
    @Published var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    static let empty = Cart(items: [])
}

struct ItemDetail: View {
    @ObservedObject var cart: Cart
    var item: Item

    var body: some View {
        VStack {
            Text(item.name)
            Button(
                action: { self.cart.items.append(self.item) },
                label: { Text("Add to cart") }
            )
        }
    }
}

struct AppView<StoreModel: Store>: View {
    let store: StoreModel
    @ObservedObject var cart: Cart = Cart.empty
    
    var body: some View {
        TabView() {
            inventoryView
                .tabItem { Text("Inventory") }
            
            cartView
                .tabItem { Text("Cart") }
        }
    }
    
    var inventoryView: some View {
        NavigationView {
            List(store.inventory) { item in
                NavigationLink(destination: ItemDetail(cart: self.cart, item: item)) {
                    Text(item.name)
                }
            }
            .navigationBarTitle("Inventory")
        }
    }
    
    var cartView: some View {
        let total = cart.items.reduce(0, { $0 + $1.price })
        return VStack {
            List(cart.items) { item in
                Text(item.name)
            }
            Text("Total: \(total)")
        }
    }
}

class AppView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AppView(store: UnoMarket())
        }
    }
}
