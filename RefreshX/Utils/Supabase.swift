//
//  Supabase.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import Foundation
import Supabase

let supabase  = SupabaseClient(
    supabaseURL: URL(string: supabaseProjetcURL)!,
    supabaseKey: supabaseAPIKey
)
