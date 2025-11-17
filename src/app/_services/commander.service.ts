import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class CommanderService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getCommanders() {
    // console.log(this.apiUrl);
    return this.http.get(`${this.apiUrl}/commander`);
  }
}
